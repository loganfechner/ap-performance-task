local tilesize = require "tilesize"
local Bullet = require "bullet"
local World = require "world"
local Player = {}

function Player:initialize(room, world)
	self.bullet = {
		list = {},
		width = 2,
		height = 2,
		speed = 100,
		minAtkPwr = 10,
		maxAtkPwr = 20
	}

	self.x = math.floor(room.x + room.width / 2) * tilesize
	self.y = math.floor(room.y + room.height / 2) * tilesize
	self.width = tilesize
	self.height = tilesize
	self.speed = 65

	world:add(self, self.x, self.y, self.width, self.height)
end

function Player:update(dt, world, drawList)
	self:move(dt, world)
	self:updateBullets(dt, world, drawList)
end

function Player:move(dt, world)
	local dx, dy = 0, 0

	if love.keyboard.isDown("d") then
		dx = self.speed
	end
	if love.keyboard.isDown("a") then
		dx = -self.speed
	end
	if love.keyboard.isDown("w") then
		dy = -self.speed
	end
	if love.keyboard.isDown("s") then
		dy = self.speed
	end

	local goalX, goalY = self.x + dx * dt, self.y + dy * dt
	self.x, self.y, cols = world:move(self, goalX, goalY)
end

function Player:fireBullet(key, world)
	local width, height = self.bullet.width, self.bullet.height
	local atkPwr = math.random(self.bullet.minAtkPwr, self.bullet.maxAtkPwr)
	local speed = self.bullet.speed

	if key == "up" then
		local x = (self.x + self.width / 2) - (self.bullet.width / 2)
		local y = self.y - self.bullet.height
		local bullet = Bullet:new(x, y, x, y-5, width, height, atkPwr, speed)

		self.bullet.list[#self.bullet.list+1] = bullet
		world:add(bullet, x, y, width, height)
	elseif key == "down" then
		local x = (self.x + self.width / 2) - (self.bullet.width / 2)
		local y = self.y + self.height
		local bullet = Bullet:new(x, y, x, y+5, width, height, atkPwr, speed)

		self.bullet.list[#self.bullet.list+1] = bullet
		world:add(bullet, x, y, width, height)
	elseif key == "right" then
		local x = self.x + self.width
		local y = (self.y + self.height / 2) - (self.bullet.height / 2)
		local bullet = Bullet:new(x, y, x+5, y, width, height, atkPwr, speed)

		self.bullet.list[#self.bullet.list+1] = bullet
		world:add(bullet, x, y, width, height)
	elseif key == "left" then
		local x = self.x - self.bullet.width
		local y = (self.y + self.height / 2) - (self.bullet.height / 2)
		local bullet = Bullet:new(x, y, x-5, y, width, height, atkPwr, speed)

		self.bullet.list[#self.bullet.list+1] = bullet
		world:add(bullet, x, y, width, height)
	end
end

local function aabb(bullet, x, y, w, h)
	return bullet.x1 + bullet.width > x and bullet.x1 < x + w and
			bullet.y1 + bullet.height > y and bullet.y1 < y + h
end

local remove = table.remove
function Player:updateBullets(dt, world, drawList)
	for i = #self.bullet.list, 1, -1 do
		local bullet = self.bullet.list[i]
		bullet:update(dt)
		world:update(bullet, bullet.x1, bullet.y1)

		for j = 1, #drawList do
			local p = drawList[j]
			if p.num == 1 then
				local x, y = p.x * tilesize, p.y * tilesize
				local w, h = tilesize, tilesize

				if aabb(bullet, x, y, w, h) then
					remove(self.bullet.list, i)
					world:remove(bullet)
					break
				end
			end
		end
	end

	print(world:countItems())
end

function Player:getPosition()
	return self.x, self.y
end

function Player:draw()
	love.graphics.setColor(255,255,255)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

	if #self.bullet.list > 0 then
		for i = 1, #self.bullet.list do
			local bullet = self.bullet.list[i]

			love.graphics.setColor(40,255,40)
			love.graphics.rectangle("fill", bullet.x1, bullet.y1, bullet.width, bullet.height)
		end
	end
end

return Player