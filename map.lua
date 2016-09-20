local class = require "middleclass"
local Map = class("Map")

function Map:initialize(width, height)
	self.data = {}
	self.width = width
	self.height = height

	for y = 1, height do
		local temp = {}
		for x = 1, width do
			temp[x] = 0
		end
		self.data[#self.data+1] = temp
	end
end

function Map:loop(f)
	for y = 1, self.height do
		for x = 1, self.width do
			f(x, y)
		end
	end
end

function Map:print()
	for y = 1, self.height do
		local line = ""
		for x = 1, self.width do
			line = line .. self.data[y][x] .. " "
		end
		print(line)
	end
end

return Map