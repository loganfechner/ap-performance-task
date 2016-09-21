math.randomseed(os.time())
math.random();math.random();math.random();

local Dungeon = require "dungeon"
local Hud = require "hud"
-- local Minimap = require "minimap"
local MST = require "mst"
local Player = require "player"
local tilesize = require "tilesize"
local Viewport = require "viewport"
local World = require "world"

function love.load()
	love.graphics.setBackgroundColor(30,30,30)

	Dungeon:initialize()
	MST:initialize(Dungeon:getRooms())
	Dungeon:generateDoors(MST:getTree())	
	Dungeon:generateDrawList()
	World:initialize(Dungeon:getDrawList())

	local room = Dungeon:getRoom(1)
	Player:initialize(room, World:getWorld())

	Viewport:initialize(Player.x, Player.y, 2.4)
end

function love.update(dt)
	-- print(collectgarbage("count"))
	Player:update(dt, World:getWorld(), Dungeon:getDrawList())

	-- Camera/Viewport
	for i = 1, #Dungeon.rooms do
		local room = Dungeon.rooms[i]
		Viewport:roomConstraint(Player, room)
	end
end

function love.draw()
	Viewport:attach()
		Dungeon:draw()
		-- MST:draw()
		Player:draw()

		--[[
		local x, y = Viewport.camera.x, Viewport.camera.y
		love.graphics.points(Viewport.camera:position())
		local scale = Viewport.camera.scale
		local w, h = love.graphics.getWidth() / scale, love.graphics.getHeight() / scale
		-- Minimap:draw(x + w / 6, y + 4 - h / 2, Dungeon.map.width, Dungeon.map.height, Dungeon.map.data)
		Minimap:draw(x + w / 30, y - h / 2.2, Dungeon.map.width, Dungeon.map.height, Dungeon.map.data)
		]]
	Viewport:detach()
	Hud:draw()
end

function love.keypressed(key)
	if key == "r" then
		Dungeon:initialize()
		MST:initialize(Dungeon:getRooms())
		Dungeon:generateDoors(MST:getTree())
		Dungeon:generateDrawList()
		World:initialize(Dungeon:getDrawList())

		local room = Dungeon:getRoom(1)
		Player:initialize(room, World:getWorld())
	end
	if key == "escape" then
		love.event.quit()
	end

	Player:fireBullet(key, World:getWorld())
end