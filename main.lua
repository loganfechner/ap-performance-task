math.randomseed(os.time())
math.random();math.random();math.random();

-- TODOS: Dungeon needs an down ladder to new level

local inspect = require "inspect"
local Dungeon = require "dungeon"
local Hud = require "hud"
local MST = require "mst"
local Player = require "player"
local tilesize = require "tilesize"
local Viewport = require "viewport"
local World = require "world"

local stats = {
	health = 65,
	speed = 105,
	ammo = 35,
	rof = .2,
	minAtkPwr = 15,
	maxAtkPwr = 30
}

local depth = 0
function loadGame()
	if depth == 0 then
		Dungeon:initialize(0)
	else
		Dungeon:initialize(Dungeon.depth)
	end
	Dungeon:increaseDepth()
	MST:initialize(Dungeon:getRooms())
	Dungeon:generateDoors(MST:getTree())	
	Dungeon:generateDrawList()
	World:initialize(Dungeon:getDrawList())

	local room = Dungeon:getRoom(1)
	Player:initialize(room, World:getWorld(), stats)

	-- 2.4
	Viewport:initialize(Player.x, Player.y, 2)

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

	loadGame()
end

function love.update(dt)
	if Player.health > 0 then
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

		print(#World.enemies)

		-- print(Player.health, stats.health)
	end
end

function love.draw()
	Viewport:attach()
		Dungeon:draw()
		MST:draw()
		Player:draw()
		
		World:draw()

	Viewport:detach()
	Hud:drawPlayerStats()
	if Player.health > 0 then
		Hud:drawLevelStatus(Dungeon.complete, Dungeon.depth, 300, 300)
	else
		Hud:drawDeadStatus(Dungeon.depth)
	end
end

function love.keypressed(key)
	if key == "r" and Dungeon.complete then
		loadGame()	
	end
	if key == "escape" then
		love.event.quit()
	end

	Player:fireBullet(key, World:getWorld())
end