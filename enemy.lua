local class = require "middleclass"
local tilesize = require "tilesize"
local Bullet = require "bullet"
local Timer = require "timer"
local Enemy = class("Enemy")

local function aabb(bullet, x, y, w, h)
	return bullet.x1 + bullet.width > x and bullet.x1 < x + w and
			bullet.y1 + bullet.height > y and bullet.y1 < y + h
end

function Enemy:initialize(x, y)
	self.x = x
	self.y = y
	self.width = tilesize / 1
	self.height = self.width
	self.kind = "enemy"
	self.maxHealth = 75
	self.health = self.maxHealth
	self.rof = math.random(.6, 1.8)

	self.canShoot = true
	self.shootTimer = Timer:new(self.rof)
	self.bullet = {
		list = {},
		width = 2,
		height = 2,
		speed = 160,
		minAtkPwr = 4,
		maxAtkPwr = 12
	}
end

function Enemy:update(dt, world, drawList, player)
	self:updateTimer(dt)
	self:updateBullets(dt, world, drawList, player)
end

function Enemy:updateTimer(dt)
	self.shootTimer:update(dt, function()
		self.canShoot = true
	end)
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

function Enemy:fireBullets(x, y, world)
	if self.canShoot then
		local w, h = 4, 4
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
end

function Enemy:draw()
	-- health bar
	love.graphics.setColor(255,0,0)
	local w = 35 * (self.health / self.maxHealth)
	love.graphics.rectangle("fill", self.x - 10, self.y - 12, w, 6)

	love.graphics.setColor(255,0,255)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

	for i = 1, #self.bullet.list do
		local bullet = self.bullet.list[i]
		love.graphics.setColor(0,255,255)
		love.graphics.rectangle("fill", bullet.x1, bullet.y1, bullet.width, bullet.height)
	end
end

return Enemy