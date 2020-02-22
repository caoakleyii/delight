require 'server.server'
require 'lib.networking.networking'
require 'lib.player_spawner'
require 'lib.entity_system'

function love.load()
    math.randomseed(love.timer.getTime() * 1000)
    server:start()
end

function love.update(dt)
    server:receive()

    for _, c in ipairs(entity_system.characters) do
        c:update(dt)
    end
end