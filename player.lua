local inspect = require "inspect"
local tilesize = require "tilesize"
local Animation = require "animation"
local Bullet = require "bullet"
local SoundFX = require "soundfx"
local Timer = require "timer"
local World = require "world"
local Player = {}

function Player:consts(health, ammo, speed, rof, minAtkPwr, maxAtkPwr)
	self.maxHealth = health or 100
	self.health = health
	self.maxAmmunition = ammo or 50
	self.maxSpeed = speed
	self.speed = speed or 105
	self.rof = rof or .2
	self.minAtkPwr = 15 or minAtkPwr
	self.maxAtkPwr = 30 or maxAtkPwr
end

local image = love.graphics.newImage("img/tileset.png")
function Player:initialize(room, world, stats)
	self.kind = "player"
	self.bullet = {
		list = {},
		width = 6,
		height = 6,
		speed = 425,
		minAtkPwr = self.minAtkPwr,
		maxAtkPwr = self.maxAtkPwr
	}

	self:consts(
		stats.health, 
		stats.ammo, 
		stats.speed,
		stats.rof, 
		stats.minAtkPwr, 
		stats.maxAtkPwr
	)

	self.x = math.floor(room.x + room.width / 2) * tilesize
	self.y = math.floor(room.y + room.height / 2) * tilesize
	self.width = tilesize
	self.height = tilesize

	self.walking = false
	self.walkRate = 2*self.speed * 10^-3
	self.walkTimer = Timer:new(self.walkRate)

	self.shootTimer = Timer:new(self.rof)
	self.canShoot = true
	self.canContinue = false

	self.ammunition = self.maxAmmunition

	world:add(self, self.x, self.y, self.width, self.height)

	self.animations = {
		{
			name = 'RunRight',
			animation = Animation:new(image, 1, 4, self.speed * 10^-3, self.x, self.y)
		},
		{
			name = 'RunLeft',
			animation = Animation:new(image, 5, 8, self.speed * 10^-3, self.x, self.y)
		},
		{
			name = 'RunUp',
			animation = Animation:new(image, 9, 12, self.speed * 10^-3, self.x, self.y)
		},
		{
			name = 'RunDown',
			animation = Animation:new(image, 13, 16, self.speed * 10^-3, self.x, self.y)
		},
		{
			name = 'IdleRight',
			animation = Animation:new(image, 17, 18, .4, self.x, self.y)
		},
		{
			name = 'IdleLeft',
			animation = Animation:new(image, 19, 20, .4, self.x, self.y)
		}
	}
	self.currentAnimation = "IdleRight"
	self.dead = false
end

function Player:update(dt, world, drawList, enemies)
	self:move(dt, world, drawList)
	self:updateBullets(dt, world, drawList, enemies)
	self:updateTimers(dt)
	self:updateAnimations(dt)
	self:updateDead()
end

function Player:updateAnimations(dt)
	for _, v in ipairs(self.animations) do
		if v.name == self.currentAnimation then
			v.animation:update(dt)
		end
	end
end

local function collisionFilter(item, other)
	if other.kind ~= "powerup" and other.kind ~= "exit" then
		return "slide"
	else
		return "cross"
	end
end

function Player:move(dt, world, drawList)
	local dx, dy = 0, 0

	if love.keyboard.isDown("w") then
		dy = -self.speed
		self.currentAnimation = "RunUp"
	end
	if love.keyboard.isDown("s") then
		dy = self.speed
		self.currentAnimation = "RunDown"
	end
	if love.keyboard.isDown("d") then
		dx = self.speed
		self.currentAnimation = "RunRight"
	end
	if love.keyboard.isDown("a") then
		dx = -self.speed
		self.currentAnimation = "RunLeft"
	end

	if dx == 0 and dy == 0 then
		if self.currentAnimation == 'RunDown' or self.currentAnimation == 'RunLeft' then
			self.currentAnimation = 'IdleLeft'
		end
		if self.currentAnimation == 'RunUp' or self.currentAnimation == 'RunRight' then
			self.currentAnimation = 'IdleRight'
		end
		self.walking = false
	else
		self.walking = true
	end

	local goalX, goalY = self.x + dx * dt, self.y + dy * dt
	self.x, self.y, cols, len = world:move(self, goalX, goalY, collisionFilter)
	self:updateCollisions(cols, len, world, drawList)

	for i = 1, len do
		local col = cols[i]
		-- print(inspect(col))
	end
end

local function aabb(bullet, x, y, w, h)
	return bullet.x1 + bullet.width > x and bullet.x1 < x + w and
			bullet.y1 + bullet.height > y and bullet.y1 < y + h
end

local remove = table.remove
function Player:updateBullets(dt, world, drawList, enemies)
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

		for j = 1, #enemies do
			local enemy  = enemies[j]
			if aabb(bullet, enemy.x, enemy.y, enemy.width, enemy.height) then
				enemy:hurtEnemy(bullet.atkPwr)
				remove(self.bullet.list, i)
				world:remove(bullet)
				break
			end
		end
	end
end

function Player:updateTimers(dt)
	self.shootTimer:update(dt, function()
		self.canShoot = true
	end)

	self.walkTimer:update(dt, function()
		if self.walking then
			SoundFX:play("walk")
		end
	end)
end

local remove = table.remove
function Player:updateCollisions(cols, len, world, drawList)
	for i = 1, len do
		local col = cols[i]
		if col.other.kind == "powerup" then
			local name = col.other.name
			if name == "ammunition" then
				self.ammunition = col.other.ammunition(self.ammunition, self.maxAmmunition)
			end
			if name == "health" then
				self.health = col.other.health(self.health, self.maxHealth)
			end
			if name == "speed" then
				self.speed = col.other.speed(self.speed + 20)
				if self.rof > .1 then
					self.rof = self.rof - .008
				end
			end

			SoundFX:play("powerup")
			-- Remove powerup from world
			world:remove(col.other)
			local x, y = col.otherRect.x / col.otherRect.w, col.otherRect.y / col.otherRect.h
			for i = #drawList, 1, -1 do
				local p = drawList[i]
				if p.x == x and p.y == y then
					remove(drawList, i)
				end
			end

			break	
		end
		if col.other.kind == "exit" then
			self.canContinue = true
		end
	end

	if len <= 0 then
		self.canContinue = false
	end
end

function Player:updateDead()
	if self.health <= 0 then
		self.dead = true
		SoundFX:play("killed")
		self.health = 0
	end
end

function Player:isDead()
	return self.dead
end

function Player:fireBullet(key, world)
	if self.canShoot and self.ammunition > 0 then
		local width, height = self.bullet.width, self.bullet.height
		local atkPwr = math.random(self.minAtkPwr, self.maxAtkPwr)
		local speed = self.bullet.speed

		if key == "up" then
			local x = (self.x + self.width / 2) - (self.bullet.width / 2)
			local y = self.y - self.bullet.height
			local bullet = Bullet:new(x, y, x, y-5, width, height, atkPwr, speed)

			self.bullet.list[#self.bullet.list+1] = bullet
			world:add(bullet, x, y, width, height)
		elseif key == "down" then
			local x = (self.x + self.width / 2) - (self.bullet.width / 2)
			local y = self.y + self.height
			local bullet = Bullet:new(x, y, x, y+5, width, height, atkPwr, speed)

			self.bullet.list[#self.bullet.list+1] = bullet
			world:add(bullet, x, y, width, height)
		elseif key == "right" then
			local x = self.x + self.width
			local y = (self.y + self.height / 2) - (self.bullet.height / 2)
			local bullet = Bullet:new(x, y, x+5, y, width, height, atkPwr, speed)

			self.bullet.list[#self.bullet.list+1] = bullet
			world:add(bullet, x, y, width, height)
		elseif key == "left" then
			local x = self.x - self.bullet.width
			local y = (self.y + self.height / 2) - (self.bullet.height / 2)
			local bullet = Bullet:new(x, y, x-5, y, width, height, atkPwr, speed)

			self.bullet.list[#self.bullet.list+1] = bullet
			world:add(bullet, x, y, width, height)
		end

		if key == "left" or key == "up" or key == "down" or key == "right" then
			SoundFX:play("shoot")
			self.canShoot = false
			self.ammunition = self.ammunition - 1
		end
	end
end

function Player:damagePlayer(atkPwr)
	self.health = self.health - atkPwr
	SoundFX:play("hit", 1.0)
end

function Player:getPosition()
	return self.x, self.y
end

function Player:draw()
	love.graphics.setColor(255, 255, 255)
	for _, v in ipairs(self.animations) do
		if v.name == self.currentAnimation then
			v.animation:draw(self.x, self.y)
		end
	end	

	if #self.bullet.list > 0 then
		for i = 1, #self.bullet.list do
			local bullet = self.bullet.list[i]

			love.graphics.setColor(40,255,40)
			love.graphics.rectangle("fill", bullet.x1, bullet.y1, bullet.width, bullet.height)
		end
	end
end

return Player