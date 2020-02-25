require 'server.server'
require 'lib.networking.networking'
require 'lib.player_spawner'
require 'lib.entity_system'

-- 60 hz tick rate
local last_updated = 1.0
local update_time = 1.0

function love.load()
    math.randomseed(love.timer.getTime() * 1000)
    server:start()
end

function love.update(dt)
    server:receive()

    for _, c in ipairs(entity_system.characters) do
        c:update(dt)
    end

    -- Anything that should happen at ~ 60hz should happen within this block
    if last_updated >= update_time then
        last_updated = 0
        for _, c in ipairs(entity_system.characters) do
            c:lerp()
        end
    end

    last_updated = last_updated + dt
end