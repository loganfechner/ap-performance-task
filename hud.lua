local Player = require "player"
local Hud = {}

ammofont = love.graphics.newFont("fonts/newfont.ttf", 23)
displayfont = love.graphics.newFont("fonts/newfont.ttf", 12)

function Hud:drawPlayerStats()
	love.graphics.setColor(255,255,255)
	love.graphics.setFont(displayfont)
	love.graphics.print("Ammo", love.graphics.getWidth() - 160, love.graphics.getHeight() - 30)
	love.graphics.setFont(ammofont)
	love.graphics.print(Player.ammunition, love.graphics.getWidth() - 100,  love.graphics.getHeight() - 30)

	local h = 40
	local w = Player.health * 2
	love.graphics.setColor(255,255,255)
	love.graphics.setFont(displayfont)
	love.graphics.print("Health", love.graphics.getWidth() - (w+275), love.graphics.getHeight() - h + 10)

	love.graphics.setColor(255,35,35)

	love.graphics.rectangle("fill", love.graphics.getWidth() - (w+185), love.graphics.getHeight() - (h + 10), w, h)
end

function Hud:drawLevelStatus(status, depth, x, y)
	if status then
		local depth = tostring(depth)

		love.graphics.setColor(255,255,255)
		love.graphics.setFont(displayfont)
		love.graphics.print("LEVEL " .. depth .. " complete", x, y - 25)
		love.graphics.print("Press 'f' continue to the next level", x - 135, y)
	end
end

function Hud:drawDeadStatus(depth)
	local s = "You have died"
	local len = string.len(s)

	love.graphics.setColor(255,255,255)
	love.graphics.setFont(displayfont)
	love.graphics.print(s, (love.graphics.getWidth()/2)-(len*12/2), 275)
	love.graphics.print("Press 'f' to play a new game", 210, 300)
end

function Hud:drawBackgroundOverlay()
	love.graphics.setColor(0,0,0,150)
	local w = Player.health * 2 + 288
	local h = 65
	local x = love.graphics.getWidth() - w
	local y = love.graphics.getHeight() - h

	love.graphics.rectangle("fill", x, y, w, h)
end

return Hud