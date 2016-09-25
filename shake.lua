local Shake = {}

Shake.growth = 5
Shake.amplitude = 3
Shake.frequency = 100

local amount
local time

function Shake.reset()
    amount = 1
    time = 0
end

function Shake.update(dt)
    amount = math.max(1, amount ^ 0.9)
    time = time + dt
end

function Shake.more(growth)
    amount = amount + growth
end

function Shake.preDraw()
    local shakeFactor = Shake.amplitude * math.log(amount)
    local waveX = math.sin(time * Shake.frequency)
    local waveY = math.cos(time * Shake.frequency)

    love.graphics.push()
    love.graphics.translate(shakeFactor * waveX, shakeFactor * waveY)
end

function Shake.postDraw()
    love.graphics.pop()
end

return Shake
