local Map = require "map"
local tilesize = require "tilesize"
local Dungeon = {}

local function pointInRoom(x, y, room)
	return x > room.x and x < room.x + room.width and 
		y > room.y and y < room.y + room.height, room
end

function Dungeon:initialize(width, height)
	if self.map then
		self.map = nil
	end
	if self.rooms then
		self.rooms = nil
	end
	if self.drawList then
		self.drawList = nil
	end

	self.maxEnemies = 16
	self.maxPowerups = 6

	self.maxRooms = 5
	self.numRooms = 0
	self.roomWidth = 16
	self.roomHeight = 12
	self.doorWidth = 5


	local width = width or 2 * ((self.roomWidth + 2) * self.maxRooms)
	local height = height or 2 * ((self.roomHeight + 2) * self.maxRooms)
	self.map = Map:new(width, height)
	self.rooms = {}
	self.drawList = {}

	self:generateRooms()
	self:generatePowerups()
	self:generateEnemies()
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
			if self.map.data[room.y-room.height-1][room.x] == 0 then
				self:placeRoom(room.x, room.y-room.height-1, room.width,
					room.height)
				self.numRooms = self.numRooms + 1
			end
			y = room.y - room.height - 1
		end
		-- South
		if dir == 2 then
			if self.map.data[room.y+room.height+1][room.x] == 0 then
				self:placeRoom(room.x, room.y+room.height+1, room.width,
					room.height)
				self.numRooms = self.numRooms + 1
			end
			y = room.y + room.height + 1
		end
		-- East
		if dir == 1 then
			if self.map.data[room.y][room.x+room.width+1] == 0 then
				self:placeRoom(room.x+room.width+1, room.y, room.width,
					room.height)
				self.numRooms = self.numRooms + 1
			end
			x = room.x + room.width + 1
		end
		-- West
		if dir == 3 then
			if self.map.data[room.y][room.x-room.width-1] == 0 then
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
		if num ~= 0 then
			self.drawList[#self.drawList+1] = {
				x = x,
				y = y,
				num = num
			}
		end
	end)
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
				self.map.data[r2.y][x] = 0
				self.map.data[r2.y-1][x] = 0
			end
		end
		-- South of room 1
		if r1.y > r2.y and r1.x == r2.x then
			for x = r2.x + doorWidth, r2.x + r2.width - doorWidth do
				self.map.data[r1.y][x] = 0
				self.map.data[r1.y-1][x] = 0
			end
		end
		-- East of room 1
		if r1.x < r2.x and r1.y == r2.y then
			for y = r2.y + doorWidth, r2.y + r2.height - doorWidth do
				self.map.data[y][r2.x] = 0
				self.map.data[y][r2.x-1] = 0
			end
		end
		-- West of room 1
		if r1.x > r2.x and r1.y == r2.y then
			for y = r2.y + doorWidth, r2.y + r2.height - doorWidth do
				self.map.data[y][r1.x] = 0
				self.map.data[y][r1.x-1] = 0
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
end

function Dungeon:generateEnemies()
	local random = math.random
	local nEnemies = random(3, self.maxEnemies)

	for i = 1, nEnemies do
		local n = random(1, self.numRooms)
		local room = self:getRoom(n)

		local x = random(room.x + 1, room.x + room.width - 1)
		local y = random(room.y + 1, room.y + room.height - 1)

		if self.map.data[y][x] == 0 then
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

function Dungeon:getDrawList()
	return self.drawList
end

function Dungeon:draw()
	for i = 1, #self.drawList do
		local tile = self.drawList[i]
		if tile.num == 1 then
			love.graphics.setColor(255,255,255)
			love.graphics.rectangle("line", tile.x*tilesize, tile.y*tilesize, tilesize, tilesize)

		elseif tile.num == 3 then
			love.graphics.setColor(0,255,0)
			love.graphics.rectangle("fill", tile.x*tilesize, tile.y*tilesize, tilesize, tilesize)
		end
	end

	love.graphics.setColor(255,0,0)
	love.graphics.rectangle("line", tilesize, tilesize, self.map.width * tilesize, self.map.height * tilesize)
end

return Dungeon