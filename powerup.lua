local class = require "middleclass"
local Powerup = class("Powerup")

function Powerup:initialize(name, x, y)
	self.name = name

	if name == "speed" then
		self.sprite = love.graphics.newImage("img/powerup-speed.png")
		self.speed = function(s) return s end
	elseif name == "ammunition" then
		self.sprite = love.graphics.newImage("img/powerup-ammunition.png")
		self.ammunition = function(a, aMax)
			local ammo = math.random(20, aMax-10)
			local r = a + ammo
			return r
		end
	elseif name == "health" then
		self.sprite = love.graphics.newImage("img/powerup-health.png")
		self.health = function(h, hMax)
			local health = math.random(20, hMax-10)
			local r = h + health
			return r
		end
	end
	self.sprite:setFilter("nearest", "nearest")

	self.x, self.y = x, y
	self.width = self.sprite:getWidth()
	self.height = self.sprite:getHeight()
end

function Powerup:draw()
	love.graphics.setColor(255,255,255)
	love.graphics.draw(self.sprite, self.x, self.y)
end

return Powerup