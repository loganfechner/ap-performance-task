local Camera = require "camera"
local tilesize = require "tilesize"
local World = require "world"
local Viewport = {}

function Viewport:initialize(x, y, scale)
	local camera = Camera(x, y)
	camera:zoomTo(scale)
	self.camera = camera
	self.x = x
	self.y = y
	self.scale = scale
end

function Viewport:roomConstraint(a, room)
	local x, y, w, h = room.x * tilesize, room.y * tilesize,
						(room.width + 1) * tilesize, (room.height + 1) * tilesize
	if World.aabb(a, x, y, w, h) then
		self.camera:lookAt((x + w / 2), (y + h / 2))
	end
end

function Viewport:lockToPlayer(x, y)
	self.camera:lookAt(x, y)
end

function Viewport:attach()
	self.camera:attach()
end

function Viewport:detach()
	self.camera:detach()
end

return Viewport