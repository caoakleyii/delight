require 'lib.networking.networking'
require 'client.client'
require 'lib.player_spawner'
require 'lib.entity_system'

function love.load()
    client:connect()
end

function love.update(dt)
    client:receive()

    for _, c in ipairs(entity_system.characters) do
        c:update(dt)
    end
end

function love.draw()
    for _, c in ipairs(entity_system.characters) do
        c:draw()
    end
end

function love.quit()
    client:disconnect()
    return false
end