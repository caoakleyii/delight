local NETWORK_MESSAGE_TYPES = require 'lib.types.network_message_types'
local COLLISION_SIGNAL_TYPES = require 'lib.types.collision_signal_types'
local ENTITY_CATEGORIES = require 'lib.types.entity_categories'
local Actor = require 'models.actor'
local ShootProjectile = require 'models.actions.shoot_projectile'
local HealthBar = require 'models.health_bar'

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
    character.aim_angle = 0
    character.friction = 1.0
    character.size = 25
    character.shoot_rpm = 0.1
    character.last_shot_time = 0.0
    character.shoot_projectile = ShootProjectile:new()
    character.groups = { Player = true }
    character.current_health = 100
    character.max_health = 100
    character.health_bar = HealthBar:new(character)
    character.destroyed = false
    character.world = nil
    self.__index = self
    return setmetatable(character, self)
end

-- Love2D Events
function Character:load(world)
    self:spawn_body(world)
    self.world = world
    networking:signal(NETWORK_MESSAGE_TYPES.player_inputs, self, self.on_player_inputs)
    networking:signal(NETWORK_MESSAGE_TYPES.player_input_release, self, self.on_player_inputs_release)
    networking:signal(NETWORK_MESSAGE_TYPES.player_angle, self, self.on_player_angle)
    networking:signal(NETWORK_MESSAGE_TYPES.lerp, self, self.on_lerp)
    networking:signal(NETWORK_MESSAGE_TYPES.disconnect, self, self.on_disconnect)
    networking:signal(NETWORK_MESSAGE_TYPES.damage, self, self.on_damage)
    networking:signal(NETWORK_MESSAGE_TYPES.destroy, self, self.on_destroy)

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
                self:get_aim_angle()
                client:send(NETWORK_MESSAGE_TYPES.player_inputs, self.id, { key = key, aim_angle = self.aim_angle })
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
    if self.destroyed then
        if self.keys_down['r'] then
            self.position = { x = 0, y = 0 }
            self:spawn_body(self.world)
        end
        return
    end

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

    if self.keys_down['1'] then
        if self.last_shot_time <= 0 then
            if self.local_player then
                self:get_aim_angle()
                client:send(NETWORK_MESSAGE_TYPES.player_angle, self.id, { aim_angle = self.aim_angle})
            end
            local position_x = math.floor(self.position.x + (math.cos(self.aim_angle) * (self.size)))
            local position_y = math.floor(self.position.y + (math.sin(self.aim_angle) * (self.size)))
            self.shoot_projectile:shoot(self.aim_angle, position_x, position_y, false)
            self.last_shot_time = self.shoot_rpm
        end
    end

    if self.body:getX() < 0 then
        self.body:setPosition(0, self.body:getY())
    end
    if self.body:getY() < 0 then
        self.body:setPosition(self.body:getX(), 0)
    end

    self.position = { x = self.body:getX(), y = self.body:getY() }

    if self.last_shot_time > 0 then
        self.last_shot_time = self.last_shot_time - dt
    end
end

function Character:draw()
    if self.destroyed and self.local_player then
        love.graphics.setColor(1,0,0,1)
        love.graphics.print('Press "R" to respawn!', love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
        return
    end

    self.health_bar:draw()

    love.graphics.setColor(0,0,1,1)
    love.graphics.polygon('line', self.body:getWorldPoints(self.shape:getPoints()))
end

function Character:get_aim_angle()
    if self.local_player then
        local x, y =  love.mouse.getPosition()
        local mouse_position = { x = x, y = y }
        self.aim_angle = math.rad_between_two_points(self.position, mouse_position)
    end
end

function Character:damage(damage_amount)
    if server then
        -- broadcast damage
        local data = { damage_amount = damage_amount}
        server:broadcast(NETWORK_MESSAGE_TYPES.damage, self.id, data)
        self:on_damage(data)
    end
end

function Character:on_damage(data)
    self.current_health = self.current_health - data.damage_amount

    if self.current_health < 0 then
        self.current_health = 0
        if server then
            server:broadcast(NETWORK_MESSAGE_TYPES.destroy, self.id, {})
            self:on_destroy()
        end
    end
end

function Character:on_destroy()
    self.destroyed = true
    self.body:destroy()
end

function Character:spawn_body(world)
    self.body = love.physics.newBody(world, self.size / 2, self.size / 2, "dynamic")
    self.shape = love.physics.newRectangleShape(self.size, self.size)
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.fixture:setFriction(self.friction)
    self.fixture:setFilterData(ENTITY_CATEGORIES.player, ENTITY_CATEGORIES.everything, 0)
    self.body:setFixedRotation(true)
    self.fixture:setUserData(self)
    self.body:setPosition(self.position.x, self.position.y)
    self.current_health = self.max_health
    self.destroyed = false
end

-- SIGNAL EVENTS
function Character:on_collide(body, collision)
    return
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

function Character:on_player_angle(data)
    self.aim_angle = data.aim_angle
    if server then
        server:broadcast_except(self.player, NETWORK_MESSAGE_TYPES.player_angle, self.id, data)
    end
end

return Character