local tilesize = require "tilesize"
local Minimap = {}

function Minimap:draw(x, y, width, height, map)
	for my = 1, height do
		for mx = 1, width do

			local num = map[my][mx]
			if num == 1 then
				love.graphics.setColor(102, 102, 153)
				love.graphics.rectangle("fill", mx / 2 + x, my / 2 + y, .5, .5)
			end
		end
	end

	love.graphics.setColor(255,0,0)
	love.graphics.rectangle("line", x, y, width / 2, height / 2)
end

return Minimap