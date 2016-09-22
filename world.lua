local bump = require "bump"
local Enemy = require "enemy"
local Powerup = require "powerup"
local tilesize = require "tilesize"
local World = {}

function World.aabb(a, x, y, w, h)
	return a.x < x + w and a.x + a.width > x and
		a.y < y + h and a.y + a.height > y
end

function World:initialize(list)
	if self.world then
		local items, len = self.world:getItems()
		for i = 1, len do
			self.world:remove(items[i])
		end
	end

	self.enemies = {}

	self.world = bump.newWorld()
	self:addBlocksToWorld(list)
end

local remove = table.remove
function World:update(dt, list, x, y, player)
	for i = #self.enemies, 1, -1 do
		local enemy = self.enemies[i]
		enemy:update(dt, self.world, list, player)
		enemy:fireBullets(x, y, self.world)

		if enemy.health < 0 then
			remove(self.enemies, i)
			self.world:remove(enemy)
			break
		end
	end
end

function World:addBlocksToWorld(list)
	for i = 1, #list do
		local p = list[i]
		if p.num == 1 then
			self:add(p.x * tilesize, p.y * tilesize, tilesize, tilesize)
		elseif p.num == 2 then
			local n = math.random(0, 2)
			local name = ""
			if n == 0 then
				name = "health"
			elseif n == 1 then
				name = "ammunition"
			elseif n == 2 then
				name = "speed"
			end

			local x, y = p.x * tilesize, p.y * tilesize
			local powerup = Powerup:new(name, x, y)
			powerup.kind = "powerup"
			self.world:add(powerup, x, y, tilesize, tilesize)
		elseif p.num == 3 then
			local enemy = Enemy:new(p.x * tilesize, p.y * tilesize, tilesize / 2, tilesize / 2)
			self.enemies[#self.enemies+1] = enemy
			self.world:add(enemy, enemy.x, enemy.y, tilesize, tilesize)
		end
	end
end

function World:add(x, y, width, height, kind)
	local block = {
		kind = kind or "solid",
		x = x,
		y = y,
		width = width,
		height = height
	}
	self.world:add(block, x, y, width, height)
end

function World:getWorld()
	return self.world
end

function World:remove(item)
	self.world:remove(item)
end

function World:draw()
	local items, len = self.world:getItems()
	for i = 1, len do
		local item = items[i]
		if item.kind == "powerup" then
			item:draw()
		end
	end

	for i = 1, #self.enemies do
		self.enemies[i]:draw()
	end
end

return World