local class = require "middleclass"
local tilesize = require "tilesize"
local Animation = require "animation"
local Bullet = require "bullet"
local SoundFX = require "soundfx"
local Timer = require "timer"
local Enemy = class("Enemy")

local gnollSprites = love.graphics.newImage("img/gnoll.png")
local skeletonSprites = love.graphics.newImage("img/skeleton.png")

local function aabb(bullet, x, y, w, h)
	return bullet.x1 + bullet.width > x and bullet.x1 < x + w and
			bullet.y1 + bullet.height > y and bullet.y1 < y + h
end

function Enemy:initialize(x, y, room)
	self.x = x
	self.y = y
	self.width = tilesize / 1
	self.height = self.width
	self.kind = "enemy"
	self.maxHealth = 75
	self.health = self.maxHealth
	self.rof = math.random(.5, 1.6)

	self.room = room
	self.reachedGoal = true
	self.goalX = 0
	self.goalY = 0
	self.distance = 0
	self.dx = 0
	self.dy = 0
	self.directionX, self.directionY = 0, 0
	self.speed = math.random(100, 140)

	self.canShoot = true
	self.canSee = false
	self.shootTimer = Timer:new(self.rof)
	self.bullet = {
		list = {},
		width = 6,
		height = 6,
		speed = 575,
		minAtkPwr = 4,
		maxAtkPwr = 12
	}

	self.fovDistance = 325

	local enemyType = math.random(0, 50)
	if enemyType < 20 then
		self.animation = Animation:new(skeletonSprites, 1, 5, .2, self.x, self.y)
	else
		self.animation = Animation:new(gnollSprites, 1, 3, .2, self.x, self.y)
	end

	self.isHurt = false
	self.rateOfHurt = .3
	self.hurtTimer = Timer:new(self.rateOfHurt)
end

function Enemy:update(dt, world, drawList, player)
	self:updateTimer(dt)
	self:updateBullets(dt, world, drawList, player)
	self:updateFov(player.x, player.y)
	self:updatePosition(dt, world)
end

function Enemy:updateFov(x, y)
	local cx = self.x + self.width / 2
	local cy = self.y + self.height / 2

	local distance = math.sqrt((cx - x)^2 + (cy - y)^2)
	if distance <= self.fovDistance then
		self.canSee = true
	else
		self.canSee = false
	end
end

local function collisionFilter(item, other)
	if other.kind == "bullet" or other.kind == "powerup" or other.kind == "exit" then
		return "cross"
	else
		return "slide"
	end
end

function Enemy:updatePosition(dt, world)
	if self.reachedGoal then
		self.goalX, self.goalY = self:newPosition()

		self.directionX = self.dx / self.distance
		self.directionY = self.dy / self.distance

		self.reachedGoal = false
	end

	local goalX = self.x + self.directionX * self.speed * dt
	local goalY = self.y + self.directionY * self.speed * dt

	self.x, self.y, cols, len = world:move(self, goalX, goalY, collisionFilter)

	local temp = 0
	for i = 1, len do
		if cols[i].other.kind == "solid" then
			temp = temp + 1
		end
	end

	if temp > 0 then
		self.reachedGoal = true
	end

	world:update(self, self.x, self.y)
end

function Enemy:newPosition()
	local x = math.random(self.room.x + 2, self.room.x + self.room.width - 2) * tilesize
	local y = math.random(self.room.y + 2, self.room.y + self.room.height - 2) * tilesize

	self.distance = math.sqrt((x-self.x)^2 + (y-self.y)^2)
	self.dx = x - self.x
	self.dy = y - self.y

	return x, y
end

function Enemy:updateTimer(dt)
	self.shootTimer:update(dt, function()
		self.canShoot = true
	end)

	self.hurtTimer:update(dt, function()
		self.isHurt = false
	end, not self.isHurt)

	self.animation:update(dt)
end

local remove = table.remove
function Enemy:updateBullets(dt, world, drawList, player)
	for i = #self.bullet.list, 1, -1 do
		local bullet = self.bullet.list[i]
		bullet:update(dt)
		world:update(bullet, bullet.x1, bullet.y1)

		for j = 1, #drawList do
			local p = drawList[j]
			if p.num == 1 then
				local x, y = p.x * tilesize, p.y * tilesize
				local w, h = tilesize, tilesize

				if aabb(bullet, x, y, w, h) then
					remove(self.bullet.list, i)
					world:remove(bullet)
					break
				end
			end
		end

		if aabb(bullet, player.x, player.y, player.width, player.height) then
			player:damagePlayer(bullet.atkPwr)
			remove(self.bullet.list, i)
			world:remove(bullet)
			break
		end
	end
end

function Enemy:removeBullets(world)
	if #self.bullet.list > 0 then
		for i = #self.bullet.list, 1, -1 do
			local bullet = self.bullet.list[i]
			remove(self.bullet.list, i)
			world:remove(bullet)
			break
		end
		self:removeBullets(world)
	end
end

function Enemy:fireBullets(x, y, world)
	if self.canShoot and self.canSee then
		local w, h = self.bullet.width, self.bullet.height
		local atkPwr = math.random(self.bullet.minAtkPwr, self.bullet.maxAtkPwr)
		local bullet = Bullet:new(self.x + self.width / 2, self.y + self.height / 2,
			x, y, w, h, atkPwr, self.bullet.speed)
		self.bullet.list[#self.bullet.list+1] = bullet
		world:add(bullet, bullet.x1, bullet.y1, w, h)

		self.canShoot = false
	end
end

function Enemy:hurtEnemy(atkPwr)
	self.health = self.health - atkPwr
	SoundFX:play("hit")
	self.isHurt = true
	self.reachedGoal = true
end

function Enemy:draw()
	-- health bar
	love.graphics.setColor(0,0,0)
	love.graphics.rectangle("fill", self.x - 7, self.y - 14, self.maxHealth / 2 + 4, 10)
	love.graphics.setColor(255,0,0)
	local w = self.health / 2
	love.graphics.rectangle("fill", self.x - 5, self.y - 12, w, 6)

	if not self.isHurt then
		love.graphics.setColor(255,255,255)
	else
		love.graphics.setColor(255,35,35)
	end
	if self.dx > 0 then
		self.animation:draw(self.x, self.y, 1, 1)
	else
		self.animation:draw(self.x + self.width, self.y, -1, 1)
	end

	for i = 1, #self.bullet.list do
		local bullet = self.bullet.list[i]
		love.graphics.setColor(255,80,175)
		love.graphics.rectangle("fill", bullet.x1, bullet.y1, bullet.width, bullet.height)
	end
end

return Enemy