local SoundFX = { sounds = {} }

local hit = love.audio.newSource("snd/Hit.wav", "static")
local shoot = love.audio.newSource("snd/GunFire.wav", "static")
local killed = love.audio.newSource("snd/Killed.wav", "static")
local powerup = love.audio.newSource("snd/Powerup.wav", "static")
local walk = love.audio.newSource("snd/walk.wav", "static")
walk:setVolume(.3)

function SoundFX:initialize()
	self:newFX("hit", hit)
	self:newFX("shoot", shoot)
	self:newFX("killed", killed)
	self:newFX("powerup", powerup)
	self:newFX("walk", walk)
end

function SoundFX:newFX(name, source)
	self.sounds[#self.sounds+1] = {
		name = name,
		source = source
	}
end

function SoundFX:play(name)
	for i = 1, #self.sounds do
		local s = self.sounds[i]
		if s.name == name then
			s.source:play()
		end
	end
end

return SoundFX