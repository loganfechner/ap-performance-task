local class = require "middleclass"
local tilesize = require "tilesize"
local Enemy = class("Enemy")

function Enemy:initialize(x, y)
	self.x = x
	self.y = y
	self.width = tilesize / 1
	self.height = self.width
	self.kind = "enemy"
end

function Enemy:draw()
	love.graphics.setColor(255,0,255)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end

return Enemy