local Player = require "player"
local Hud = {}

function Hud:draw()
	love.graphics.setColor(255,0,0)
	love.graphics.print(Player.ammunition, 10, 10)

	love.graphics.setColor(255,35,35)
	local w, h = 100 * (Player.health / Player.maxHealth), 40
	love.graphics.rectangle("fill", 10, 30, w, h)
end

return Hud