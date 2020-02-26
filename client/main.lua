require 'lib.networking.networking'
require 'client.client'
require 'lib.player_spawner'
require 'lib.entity_system'
require 'lib.ai_spawner'
require 'lib.extensions.math'

function love.load()
    client:connect()
end

function love.update(dt)
    client:receive()

    entity_system.world:update(dt)

    for _, c in ipairs(entity_system.characters) do
        c:update(dt)
    end

    for _, ai in ipairs(entity_system.ai) do
        ai:update(dt)
    end
end

function love.draw()
    for _, c in ipairs(entity_system.characters) do
        c:draw()
    end

    for _, ai in ipairs(entity_system.ai) do
        ai:draw()
    end
end

function love.quit()
    client:disconnect()
    return false
end