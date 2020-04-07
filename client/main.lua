require 'lib.extensions'
require 'lib.networking.networking'
require 'client.client'
require 'lib.player_spawner'
require 'lib.entity_system'
require 'lib.ai_spawner'

local ground = {}

function love.load()
    ground.body = love.physics.newBody(entity_system.world, 1920/ 2, 1080)
    ground.shape = love.physics.newRectangleShape(1920, 50)
    ground.fixture = love.physics.newFixture(ground.body, ground.shape)
    ground.fixture:setFriction(1.0)
    client:connect()
end

function love.update(dt)
    client:receive()

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
end

function love.draw()
    love.graphics.setBackgroundColor(192/255, 255/255, 238/255, 1)
    -- set the drawing color to green for the ground
    love.graphics.setColor(0.28, 0.63, 0.05)
    -- draw a "filled in" polygon using the ground's coordinates
    love.graphics.polygon("fill", ground.body:getWorldPoints(
                            ground.shape:getPoints()))

    for k, c in pairs(entity_system.characters) do
        if c.cleanup then
            entity_system.characters[k] = nil
        else
            c:draw()
        end
    end

    for k, ai in pairs(entity_system.ai) do
        if ai.cleanup then
            entity_system.ai[k] = nil
        else
            ai:draw()
        end
    end

    for k, o in pairs(entity_system.objects) do
        if o.cleanup then
            entity_system.objects[k] = nil
        else
            o:draw()
        end
    end
end

function love.quit()
    client:disconnect()
    return false
end