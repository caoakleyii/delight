local NETWORK_MESSAGE_TYPES = require 'lib.types.network_message_types'
local COLLISION_SIGNAL_TYPES = require 'lib.types.collision_signal_types'
local ENTITY_CATEGORIES = require 'lib.types.entity_categories'
local Actor = require 'models.actor'

local Character = Actor:new()
function Character:new()
    local character = Actor:new()
    character.id = math.random(0, 4294967295)
    character.name = ''
    character.position = { x = 0, y = 0 }
    character.type = 1
    character.local_player = false
    character.player = {}
    character.keys_down = {}
    character.speed = 2.5 * 100
    character.jump_height = 40 * 1000
    character.friction = 1.0
    character.size = 25
    character.groups = { Player = true }
    self.__index = self
    return setmetatable(character, self)
end

-- Love2D Events
function Character:load(world)
    self.body = love.physics.newBody(world, self.size / 2, self.size / 2, "dynamic")
    self.shape = love.physics.newRectangleShape(self.size, self.size)
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.fixture:setFriction(self.friction)
    self.fixture:setFilterData(ENTITY_CATEGORIES.player, ENTITY_CATEGORIES.everything, 0)
    self.body:setFixedRotation(true)
    self.fixture:setUserData(self)
    self.body:setPosition(self.position.x, self.position.y)

    networking:signal(NETWORK_MESSAGE_TYPES.player_inputs, self, self.on_player_inputs)
    networking:signal(NETWORK_MESSAGE_TYPES.player_input_release, self, self.on_player_inputs_release)
    networking:signal(NETWORK_MESSAGE_TYPES.lerp, self, self.on_lerp)
    networking:signal(NETWORK_MESSAGE_TYPES.disconnect, self, self.on_disconnect)
    entity_system:signal(COLLISION_SIGNAL_TYPES.begin_contact, self.fixture, self, self.on_collide)

    if self.local_player then
        function love.keypressed(key, scancode, isrepeat)
            if key == "escape" then
                return
            end

            self.keys_down[key] = true
            if not isrepeat then
                -- TODO: update when key mappings become a thing
                -- add check if key is a skill, then we should send angle
                client:send(NETWORK_MESSAGE_TYPES.player_inputs, self.id, { key = key })
            end
        end

        function love.keyreleased(key, scancode)
            self.keys_down[key] = nil
            -- TODO: update when key mappings become a thing
            client:send(NETWORK_MESSAGE_TYPES.player_input_release, self.id, { key = key })
        end

        function love.quit(exitstatus)
            client:send(NETWORK_MESSAGE_TYPES.disconnect, self.id)
        end
    end
end

function Character:update(dt)
    local _, yv = self.body:getLinearVelocity()
    if self.keys_down['a'] then
        self.body:setLinearVelocity(self.speed * -1, yv)
    end

    if self.keys_down['d'] then
        self.body:setLinearVelocity(self.speed, yv)
    end

    if not self.keys_down['a'] and not self.keys_down['d'] then
        self.body:setLinearVelocity(0, yv)
    end

    if self.keys_down['space'] then
        if yv == 0 then
            self.body:applyForce(0, self.jump_height * -1)
        end
    end

    if self.body:getX() < 0 then
        self.body:setPosition(0, self.body:getY())
    end
    if self.body:getY() < 0 then
        self.body:setPosition(self.body:getX(), 0)
    end
    self.position = { x = self.body:getX(), y = self.body:getY() }
end

function Character:draw()
    love.graphics.setColor(0,0,1,1)
    love.graphics.polygon('line', self.body:getWorldPoints(self.shape:getPoints()))
end

-- SIGNAL EVENTS
function Character:on_collide(body, collision)
end

function Character:on_player_inputs(data)
    self.keys_down[data.key] = true
    if server then
        server:broadcast_except(self.player, NETWORK_MESSAGE_TYPES.player_inputs, self.id, data)
    end
end

function Character:on_player_inputs_release(data)
    self.keys_down[data.key] = nil
    if server then
        server:broadcast_except(self.player, NETWORK_MESSAGE_TYPES.player_input_release, self.id, data)
    end
end

return Character