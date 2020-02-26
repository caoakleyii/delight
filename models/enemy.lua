local NETWORK_MESSAGE_TYPES = require 'lib.types.network_message_types'

local Enemy = {}
function Enemy:new()
    local enemy = {}
    enemy.id = math.random(0, 4294967295)
    enemy.name = ''
    enemy.position = { x = 100, y = 100 }
    enemy.waypoint = nil
    enemy.speed = 50
    enemy.path = false
    enemy.size = 50
    enemy.groups = { "Enemy" }
    self.__index = self
    return setmetatable(enemy, self)
end

-- Love2D Events
function Enemy:load(world)
    self.body = love.physics.newBody(world, self.size / 2, self.size / 2, "dynamic")
    self.shape = love.physics.newRectangleShape(self.size, self.size)
    self.fixture = love.physics.newFixture(self.body, self.shape, 1)
    self.fixture:setUserData(self)
    self.body:setPosition(self.position.x, self.position.y)

    networking:signal(NETWORK_MESSAGE_TYPES.lerp, self, self.on_lerp)
end

function Enemy:update(dt)

    if self.waypoint and math.distance_two_points(self.position, self.waypoint) > 1 then
        -- TODO: Make this into a re-usable function
        --       for moving a position, towards another position.
        local angle = math.rad_between_two_points(self.position, self.waypoint)
        self.position.x = self.position.x + math.cos(angle) * self.speed * dt
        self.position.y = self.position.y + math.sin(angle) * self.speed * dt
    end

    -- this can be reversed to use the love2d physics engine
    -- by using apply force on the ball, and then setting body:getX(), and body:getY() to position
    self.body:setPosition(self.position.x, self.position.y)
    self.body:setAwake(true)
end

function Enemy:draw()
    love.graphics.polygon('line', self.body:getWorldPoints(self.shape:getPoints()))
end

--  Methods
function Enemy:lerp()
    if server then
        server:broadcast(NETWORK_MESSAGE_TYPES.lerp, {
            id = self.id,
            position = {
                x = self.position.x,
                y = self.position.y
            }
        })
    end
end


-- SIGNAL EVENTS

function Enemy:on_lerp(data)
    self.position.x = data.position.x
    self.position.y = data.position.y
end

return Enemy