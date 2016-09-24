local Player = require "player"
local Hud = {}

-- ammofont = love.graphics.newFont("newfont.ttf", 23)
-- displayfont = love.graphics.newFont("newfont.ttf", 12)

function Hud:drawPlayerStats()
	love.graphics.setColor(255,0,0)
	-- love.graphics.setFont(ammofont)
	love.graphics.print(Player.ammunition, love.graphics.getWidth() - 50,  love.graphics.getHeight() - 20)

	love.graphics.setColor(35,255,35)
	local h = 40
	local w = 0
	for i = 1, Player.health do
		w = w + 2 
	end

	love.graphics.rectangle("fill", love.graphics.getWidth() - (w+55), love.graphics.getHeight() - 
		(h), w, h)
end

function Hud:drawLevelStatus(status, depth, x, y)
	if status then
		local depth = tostring(depth)

		love.graphics.setColor(0,0,255)
		-- love.graphics.setFont(displayfont)
		love.graphics.print("LEVEL " .. depth .. " complete", x, y)
		love.graphics.print("Press 'r' continue to the next level", x - 20, y + 20)
	end
end

function Hud:drawDeadStatus(depth)
	local s = "You have died"
	local len = string.len(s)

	love.graphics.setColor(255,35,35)
	-- love.graphics.setFont(displayfont)
	love.graphics.print(s, (love.graphics.getWidth()/2)-(len*5/2), 250)
end

return Hud