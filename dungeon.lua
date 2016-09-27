local Map = require "map"
local Quads = require "quads"
local tilesize = require "tilesize"
local Dungeon = {}


local backgroundSprite = love.graphics.newImage("img/background.png")
backgroundSprite:setFilter("nearest", "nearest")
local floorQuad = Quads:loadQuad(backgroundSprite, 15)
local wallQuad = Quads:loadQuad(backgroundSprite, 5)
local exitQuad = Quads:loadQuad(backgroundSprite, 9)

local function pointInRoom(x, y, room)
	return x > room.x and x < room.x + room.width and 
		y > room.y and y < room.y + room.height, room
end

function Dungeon:initialize(me, mp, mr, ma)
	if self.map then
		self.map = nil
	end
	if self.rooms then
		self.rooms = nil
	end
	if self.drawList then
		self.drawList = nil
	end

	self.maxEnemies = me or 2
	self.maxPowerups = mp or 1
	self.maxAmmoCrates = ma or 0

	self.maxRooms = mr or 6
	self.numRooms = 0
	self.roomWidth = 10
	self.roomHeight = 5
	self.doorWidth = 1


	local width = width or 2 * ((self.roomWidth + 2) * self.maxRooms)
	local height = height or 2 * ((self.roomHeight + 2) * self.maxRooms)
	self.map = Map:new(width, height)
	self.rooms = {}
	self.drawList = {
		foreground = {},
		background = {}
	}

	self.complete = false

	self:generateRooms()
	self:generatePowerups()
	self:generateEnemies()
	self:generateExit()
end

function Dungeon:increaseDifficulty(depth, existingEnemies)
	if self.maxEnemies <= 30 then
		self.maxEnemies = math.floor(self.maxEnemies + math.floor(depth / 2)) + math.ceil(existingEnemies / 2)
	end
	if self.maxPowerups <= 6 then
		self.maxPowerups = math.floor(self.maxPowerups + depth / 3)
	end
	if self.maxRooms <= 20 then
		self.maxRooms = math.floor(self.maxRooms + math.floor(depth / 2))
	end
	if self.maxAmmoCrates <= 5 and depth % 2 == 0 then
		self.maxAmmoCrates = self.maxAmmoCrates + 1
	end
end

function Dungeon:generateRooms()
	local random = math.random
	local x, y = math.ceil(self.map.width / 2), math.ceil(self.map.height / 2)
	self:placeRoom(x, y, self.roomWidth, self.roomHeight)
	self.numRooms = self.numRooms + 1

	local cx, cy = x, y
	repeat
		local dir = random(0, 3)
		local room = self.rooms[#self.rooms]
		-- North
		if dir == 0 then
			if self.map.data[room.y-room.height-1][room.x] <= 0 then
				self:placeRoom(room.x, room.y-room.height-1, room.width,
					room.height)
				self.numRooms = self.numRooms + 1
			end
			y = room.y - room.height - 1
		end
		-- South
		if dir == 2 then
			if self.map.data[room.y+room.height+1][room.x] <= 0 then
				self:placeRoom(room.x, room.y+room.height+1, room.width,
					room.height)
				self.numRooms = self.numRooms + 1
			end
			y = room.y + room.height + 1
		end
		-- East
		if dir == 1 then
			if self.map.data[room.y][room.x+room.width+1] <= 0 then
				self:placeRoom(room.x+room.width+1, room.y, room.width,
					room.height)
				self.numRooms = self.numRooms + 1
			end
			x = room.x + room.width + 1
		end
		-- West
		if dir == 3 then
			if self.map.data[room.y][room.x-room.width-1] <= 0 then
				self:placeRoom(room.x-room.width-1, room.y, room.width,
					room.height)
				self.numRooms = self.numRooms + 1
			end
			x = room.x - room.width - 1
		end

		cx, cy = x, y
	until self.numRooms >= self.maxRooms
end

function Dungeon:generateDrawList()
	self.map:loop(function(x, y)
		local num = self.map.data[y][x]
		if num > 1 then
			local list = {
				x = x,
				y = y,
				num = num
			}

			self.drawList.background[#self.drawList.background+1] = {
				x = x,
				y = y,
				num = -1
			}

			if num == 3 then
				for i = 1, #self.rooms do
					local room = self.rooms[i]
					if room.x < x and room.x + room.width > x and
					room.y < y and room.y + room.height > y then
						list.room = room
					end
				end
			end

			self.drawList.foreground[#self.drawList.foreground+1] = list
		end
		if num == 1 or num == -1 or num == 6 then
			local list = {
				x = x,
				y = y,
				num = num
			}

			self.drawList.background[#self.drawList.background+1] = list
		end
	end)
end

function Dungeon:generateExit()
	local lastRoom = self:getRoom(#self.rooms)
	local x = math.random(lastRoom.x + 2, lastRoom.x + lastRoom.width - 2)
	local y = math.random(lastRoom.y + 2, lastRoom.y + lastRoom.height - 2)
	self.map.data[y][x] = 6
end

function Dungeon:generateDoors(tree)
	local pairedRooms = {}
	-- Get paired rooms from edges of mst
	for i = 1, #tree do
		local temp = {}
		local p1 = tree[i].p1
		local p2 = tree[i].p2
		
		-- Check the first point
		for j = 1, #self.rooms do
			local col, room = pointInRoom(p1.x, p1.y, self.rooms[j])
			if col then
				temp[#temp+1] = { r = room }
			end
		end
		-- Check the second point
		for j = 1, #self.rooms do
			local col, room = pointInRoom(p2.x, p2.y, self.rooms[j])
			if col then
				temp[#temp+1] = { r = room }
			end
		end

		-- Determine if there is a pair
		if #temp > 1 then
			pairedRooms[#pairedRooms+1] = temp
		end
	end

	-- Cut out doors from paired rooms
	for i = 1, #pairedRooms do
		-- "r1" will be the relative point for directions
		local r1, r2 = pairedRooms[i][1].r, pairedRooms[i][2].r
		local doorWidth = self.doorWidth
		-- North of room 1
		if r1.y < r2.y and r1.x == r2.x then
			for x = r2.x + doorWidth, r2.x + r2.width - doorWidth do
				self.map.data[r2.y][x] = -1
				self.map.data[r2.y-1][x] = -1
			end
		end
		-- South of room 1
		if r1.y > r2.y and r1.x == r2.x then
			for x = r2.x + doorWidth, r2.x + r2.width - doorWidth do
				self.map.data[r1.y][x] = -1
				self.map.data[r1.y-1][x] = -1
			end
		end
		-- East of room 1
		if r1.x < r2.x and r1.y == r2.y then
			for y = r2.y + doorWidth, r2.y + r2.height - doorWidth do
				self.map.data[y][r2.x] = -1
				self.map.data[y][r2.x-1] = -1
			end
		end
		-- West of room 1
		if r1.x > r2.x and r1.y == r2.y then
			for y = r2.y + doorWidth, r2.y + r2.height - doorWidth do
				self.map.data[y][r1.x] = -1
				self.map.data[y][r1.x-1] = -1
			end
		end
	end
end

function Dungeon:placeRoom(x, y, width, height)
	self.map:loop(function(mx, my)
		if ((my >= y and my <= y + height) and
		(mx == x or mx == x + width)) or
		((mx >= x and mx <= x + width) and
		(my == y or my == y + height)) then
			self.map.data[my][mx] = 1
		elseif ((my > y and mx > x and mx < x + width and my < y + height)) then
		    self.map.data[my][mx] = -1
		end
	end)

	self.rooms[#self.rooms+1] = {
		x = x, y = y, width = width, height = height
	}
end

function Dungeon:generatePowerups()
	local random = math.random
	local nPowerups = random(0, self.maxPowerups)

	for i = 1, nPowerups do
		local n = random(1, self.numRooms)
		local room = self:getRoom(n)

		local x = random(room.x + 1, room.x + room.width - 1)
		local y = random(room.y + 1, room.y + room.height - 1)

		self.map.data[y][x] = 2
	end

	local nAmmoCrates = math.floor(random(1, self.maxAmmoCrates))
	for i = 1, nAmmoCrates do
		local n = random(1, self.numRooms)
		local room = self:getRoom(n)

		local x = random(room.x + 1, room.x + room.width - 1)
		local y = random(room.y + 1, room.y + room.height - 1)

		self.map.data[y][x] = 4
	end
end

function Dungeon:generateEnemies()
	local random = math.random
	local nEnemies = random(self.maxEnemies / 2, self.maxEnemies)

	for i = 1, nEnemies do
		local n = random(1, self.numRooms)
		local room = self:getRoom(n)

		local x = random(room.x + 1, room.x + room.width - 1)
		local y = random(room.y + 1, room.y + room.height - 1)

		if self.map.data[y][x] == -1 or self.map.data[y][x] == 0 then
			self.map.data[y][x] = 3
		end
	end
end

function Dungeon:getRoom(i)
	return self.rooms[i]
end

function Dungeon:getRooms()
	return self.rooms
end

function Dungeon:getDrawList(s)
	if s == "background" then
		return self.drawList.background
	elseif s == "foreground" then
		return self.drawList.foreground
	end
end

function Dungeon:getRoomFromPosition(x, y)
	for i = 1, #self.rooms do
		local room = self.rooms[i]
		if x > room.x and x < room.x + room.width and y > room.y and y < room.y + room.height then
			return room
		end
	end
end

function Dungeon:getHarmlessRoom()
	local leastEnemies = {}
	for i = 1, #self.rooms do
		local room = self.rooms[i]
		local nEnemies = 0
		local nExits = 0
		for y = room.y + 1, room.y + room.height - 1 do
			for x = room.x + 1, room.x + room.width - 1 do
				if self.map.data[y][x] == 3 then
					nEnemies = nEnemies + 1
				end
				if self.map.data[y][x] == 6 then
					nExits = nExits + 1
				end
			end
		end
		if nEnemies == 0 and nExits == 0 then
			leastEnemies[#leastEnemies+1] = {room = room, nEnemies = 0}
		elseif nEnemies > 0 and nExits == 0 then
			leastEnemies[#leastEnemies+1] = {room = room, nEnemies = nEnemies}
		end
	end
	if #leastEnemies > 0 then
		local sort = table.sort
		sort(leastEnemies, function(a, b) return a.nEnemies < b.nEnemies end)
	end
	return leastEnemies[1].room
end

function Dungeon:updateDungeonComplete(n)
	if n <= 0 then
		self.complete = true
	end
end

function Dungeon:drawFloor()
	for i = 1, #self.drawList.background do
		local tile = self.drawList.background[i]
		if tile.num == -1 then
			love.graphics.setColor(255,255,255)
			love.graphics.draw(backgroundSprite, floorQuad, tile.x*tilesize, tile.y*tilesize)
		end
		if tile.num == 6 then
			love.graphics.setColor(255,255,255)
			love.graphics.draw(backgroundSprite, exitQuad, tile.x*tilesize, tile.y*tilesize)
		end
	end
end

function Dungeon:drawWalls()
	for i = 1, #self.drawList.background do
		local tile = self.drawList.background[i]
		if tile.num == 1 then
			love.graphics.setColor(255,255,255)
			love.graphics.draw(backgroundSprite, wallQuad, tile.x*tilesize, tile.y*tilesize)
		end
	end

	-- love.graphics.setColor(255,0,0)
	-- love.graphics.rectangle("line", tilesize, tilesize, self.map.width * tilesize, self.map.height * tilesize)
end

function Dungeon:drawRoomNums()
	for i = 1, #self.rooms do
		local room = self.rooms[i]
		local x, y = room.x + 1, room.y + 1
		love.graphics.setColor(255,255,255)
		love.graphics.print(i, x * tilesize, y * tilesize)
	end
end

return Dungeon