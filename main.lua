math.randomseed(os.time())
math.random();math.random();math.random();

-- TODOS: Dungeon needs an down ladder to new level

local inspect = require "inspect"
local Dungeon = require "dungeon"
local Hud = require "hud"
local MST = require "mst"
local Player = require "player"
local SoundFX = require "soundfx"
local tilesize = require "tilesize"
local Viewport = require "viewport"
local World = require "world"

local stats = {
	health = 65,
	speed = 220,
	ammo = 35,
	rof = .35,
	minAtkPwr = 15,
	maxAtkPwr = 30
}

local depth = 0
function loadGame()
	Dungeon:initialize()
	MST:initialize(Dungeon:getRooms())
	print(#MST.tree)
	Dungeon:generateDoors(MST:getTree())
	Dungeon:generateDrawList()
	World:initialize(Dungeon:getDrawList())

	local room = Dungeon:getRoom(1)
	Player:initialize(room, World:getWorld(), stats)

	-- 2.4
	Viewport:initialize(Player.x, Player.y, 1)

	depth = depth + 1
end

function updateStats()
	stats.health = Player.health
	stats.speed = Player.speed
	stats.ammo = Player.ammunition
	stats.rof = Player.rof
	stats.minAtkPwr = Player.minAtkPwr
	stats.maxAtkPwr = Player.maxAtkPwr
end

function love.load()
	love.graphics.setBackgroundColor(30,30,30)

	SoundFX:initialize()
	loadGame()

	local items, len = World.world:getItems()
	for i = 1, len do
		print(inspect(items[i]))
	end
end

function love.update(dt)
	if not Player:isDead() then
		-- print(collectgarbage("count"))
		Player:update(dt, World:getWorld(), Dungeon:getDrawList(), World.enemies)
		World:update(dt, Dungeon:getDrawList(), Player.x, Player.y, Player)
		Dungeon:updateDungeonComplete(#World.enemies)

		-- Camera/Viewport
		-- for i = 1, #Dungeon.rooms do
		-- 	local room = Dungeon.rooms[i]
		-- 	Viewport:roomConstraint(Player, room)
		-- end
		updateStats(dt)
		Viewport:lockToPlayer(Player.x, Player.y)

		-- print(Player.health, stats.health)
	end

	love.window.setTitle(#World.enemies)
end

function love.draw()
	Viewport:attach()
		--[[
		]]
		Dungeon:draw()
		Dungeon:drawRoomNums()
		MST:draw()
		Player:draw()
		
		World:draw()
		--[[
		]]
		
		-- World:drawListNums(Dungeon:getDrawList())
	Viewport:detach()
	Hud:drawPlayerStats()

	if not Player:isDead() then
		Hud:drawLevelStatus(Dungeon.complete, depth, 300, 300)
	else
		Hud:drawDeadStatus(depth)
	end
end

function love.keypressed(key)
	if key == "r" then
		loadGame()	
	end
	if key == "escape" then
		love.event.quit()
	end

	if not Player:isDead() then
		Player:fireBullet(key, World:getWorld())
	end
end