require 'server.server'
require 'lib.networking.networking'
require 'lib.player_spawner'
require 'lib.entity_system'
require 'lib.ai_spawner'
require 'lib.extensions.math'

-- 60 hz tick rate
local TICK_RATE = 60
local last_updated = 0
local update_time = TICK_RATE / 1000

function love.load()
    math.randomseed(love.timer.getTime() * 1000)
    server:start()
    ai_spawner:spawn_ai({})
end

function love.update(dt)
    server:receive()

    entity_system.world:update(dt)

    for _, c in ipairs(entity_system.characters) do
        c:update(dt)
    end

    for _, ai in ipairs(entity_system.ai) do
        ai:update(dt)
    end

    -- Anything that should happen at the specified tick_rate should happen within this block
    if last_updated >= update_time then
        last_updated = 0
        for _, c in ipairs(entity_system.characters) do
            c:lerp()
        end

        for _, ai in ipairs(entity_system.ai) do
            ai:lerp()
        end
    end

    last_updated = last_updated + dt
end