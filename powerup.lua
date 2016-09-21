local class = require "middleclass"
local Powerup = class("Powerup")

function Powerup:initialize(name)
	self.name = name

	if name == "speed" then
		self.speed = function(s) return s end
	elseif name == "ammunition" then
		self.ammunition = function(a, aMax)
			local ammo = math.random(20, aMax-10)
			local r = a + ammo
			return r
		end
	elseif name == "health" then
		self.health = function(h, hMax)
			local health = math.random(20, hMax-10)
			local r = h + health
			return r
		end
	end
end

return Powerup