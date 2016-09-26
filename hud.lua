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
		local s1 = "LEVEL " .. depth .. " complete"
		local s2 = "Press 'f' to continue to the next level"

		local w1 = string.len(s1) * 12
		local w2 = string.len(s2) * 12

		local yOffset = 200

		love.graphics.setColor(0,0,0, 200)
		love.graphics.rectangle("fill", x - w2 / 2 - 35, y - 49 - yOffset, w2 * 1.3, 75)

		love.graphics.setColor(255,255,255)
		love.graphics.setFont(displayfont)
		love.graphics.print(s1, x - w1 / 2, y - 25 - yOffset)
		love.graphics.print(s2, x - w2 / 2, y - yOffset)

	end
end

function Hud:drawDepth(depth)
	love.graphics.setColor(0,0,0,200)
	love.graphics.rectangle("fill", 45, 35, 135, 57)
	love.graphics.setColor(255,255,255)
	love.graphics.print("LEVEL " .. depth, 65, 60)
end

function Hud:drawDeadStatus(depth)
	local yOffset = 200
	local s = "You have died"
	local len = string.len(s)

	local x, y = (love.graphics.getWidth()/2)-(len*12/2), love.graphics.getHeight() / 2 - yOffset

	love.graphics.setColor(0,0,0,200)
	love.graphics.rectangle("fill", x - 22 * 12 / 2, y - 26, 36 * 12, 12 * 7)

	love.graphics.setColor(255,255,255)
	love.graphics.setFont(displayfont)
	love.graphics.print(s, x, y)
	love.graphics.print("Press 'f' to play a new game", x - 18 * 12 / 2, y + 26)
end

function Hud:drawBackgroundOverlay()
	love.graphics.setColor(0,0,0,200)
	local w = Player.health * 2 + 288
	local h = 65
	local x = love.graphics.getWidth() - w
	local y = love.graphics.getHeight() - h

	love.graphics.rectangle("fill", x, y, w, h)
end

return Hud