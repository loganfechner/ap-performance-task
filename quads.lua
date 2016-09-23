local tilesize = require "tilesize"
local class 		= require 'middleclass'
local Quads 		= class('Quads')

function Quads:initialize(x, y, w, h)
	self.x = x
	self.y = y
	self.w = w
	self.h = h
end

function Quads:loadQuadInfo(image)
	local quadInfo = {}

	imageTileWidth = image:getWidth() / tilesize
	imageTileHeight = image:getHeight() / tilesize

	for y = 0, imageTileHeight-1 do
		for x = 0, imageTileWidth-1 do
			local quad = self:new(x * tilesize, y * tilesize, tilesize, tilesize)
			quadInfo[#quadInfo+1] = quad
		end
	end

	return quadInfo
end

function Quads:loadQuad(image, n)
	local quadInfo = self:loadQuadInfo(image)
	local info = quadInfo[n]
	return love.graphics.newQuad(info.x, info.y, info.w, info.h, image:getDimensions())
end

function Quads:loadQuads(image, f, e)
	local quads = {}
	local quadInfo = self:loadQuadInfo(image)

	for i = f, e do
		local info = quadInfo[i]
		table.insert(quads, love.graphics.newQuad(info.x, info.y, info.w, info.h, image:getDimensions()))
	end

	return quads
end

return Quads