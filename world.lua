local bump = require "bump"
local tilesize = require "tilesize"
local World = {}

function World.aabb(a, x, y, w, h)
	return a.x < x + w and a.x + a.width > x and
		a.y < y + h and a.y + a.height > y
end

function World:initialize(list)
	self.world = bump.newWorld()
	self:addBlocksToWorld(list)
end

function World:addBlocksToWorld(list)
	for i = 1, #list do
		local p = list[i]
		self:add(p.x * tilesize, p.y * tilesize, tilesize, tilesize)
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

return World