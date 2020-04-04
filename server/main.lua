require 'lib.extensions'
require 'server.server'
require 'lib.networking.networking'
require 'lib.player_spawner'
require 'lib.entity_system'
require 'lib.ai_spawner'

-- 60 hz tick rate
local TICK_RATE = 60
local last_updated = 0
local update_time = TICK_RATE / 1000

local ground = {}

function love.load()
    ground.body = love.physics.newBody(entity_system.world, 1920/ 2, 1080)
    ground.shape = love.physics.newRectangleShape(1920, 50)
    ground.fixture = love.physics.newFixture(ground.body, ground.shape)
    ground.fixture:setFriction(1.0)
    server:start()
    ai_spawner:spawn_ai({})
end

function love.update(dt)
    server:receive()

    entity_system.world:update(dt)

    for k, c in pairs(entity_system.characters) do
        if c.cleanup then
            entity_system.characters[k] = nil
        else
            c:update(dt)
        end
    end

    for k, ai in pairs(entity_system.ai) do
        if ai.cleanup then
            entity_system.ai[k] = nil
        else
            ai:update(dt)
        end
    end

    for k, o in pairs(entity_system.objects) do
        if o.cleanup then
            entity_system.objects[k] = nil
        else
            o:update(dt)
        end
    end

    -- Anything that should happen at the specified tick_rate should happen within this block
    if last_updated >= update_time then
        last_updated = 0
        for _, c in pairs(entity_system.characters) do
            if c.lerp then
                c:lerp()
            end
        end

        for _, ai in pairs(entity_system.ai) do
            if ai.lerp then
                ai:lerp()
            end
        end
    end

    last_updated = last_updated + dt
end