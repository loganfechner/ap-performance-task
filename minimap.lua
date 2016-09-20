local tilesize = require "tilesize"
local Minimap = {}

function Minimap:draw(x, y, width, height, drawList)
	-- Background
	love.graphics.setColor(244, 84, 255)
	love.graphics.rectangle("fill", x, y, width, height)

	-- Fill small solid squares
	for i = 1, #drawList do
		love.graphics.setColor(200, 65, 90)
		local item = drawList[i]
		love.graphics.rectangle("fill", item.x + x, item.y + y, 2, 2)
	end
end

return Minimap