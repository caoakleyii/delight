local NETWORK_MESSAGE_TYPES = require 'lib.types.network_message_types'
local COLLISION_SIGNAL_TYPES = require 'lib.types.collision_signal_types'
local ENTITY_CATEGORIES = require 'lib.types.entity_categories'
local GROUPS = require 'lib.types.groups'

local Actor = require 'models.actor'
local ShootProjectile = require 'models.actions.shoot_projectile'

local Enemy = Actor:new()
function Enemy:new()
    local enemy = {}
    enemy.id = math.random(0, 4294967295)
    enemy.name = ''
    enemy.position = { x = 300, y = 100 }
    enemy.waypoint = math.zero_vector()
    enemy.aggro_radius = 550
    enemy.speed = 1.5 * 100
    enemy.path = false
    enemy.size = 50
    enemy.shoot_rpm = 0.1
    enemy.last_shot_time = 0.0
    enemy.shoot_projectile = ShootProjectile:new()
    enemy.groups = { [GROUPS.enemy] = true }
    enemy.aggrod_character = nil

    self.__index = self
    return setmetatable(enemy, self)
end

-- Love2D Events
function Enemy:load(world)
    -- create enemy body
    self.body = love.physics.newBody(world, self.size / 2, self.size / 2, "dynamic")
    self.shape = love.physics.newRectangleShape(self.size, self.size)
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.fixture:setFilterData(ENTITY_CATEGORIES.scan_box, ENTITY_CATEGORIES.everything, 0)

    self.fixture:setFriction(1.0)
    self.body:setFixedRotation(true)
    self.fixture:setUserData(self)
    self.body:setPosition(self.position.x, self.position.y)

    -- create a signal for fixture colliding with enemy body
    entity_system:signal(COLLISION_SIGNAL_TYPES.begin_contact, self.fixture, self, self.on_collide)

    -- create enemy aggro radius
    self.aggro_shape = love.physics.newCircleShape(self.aggro_radius)
    self.aggro_fixture = love.physics.newFixture(self.body, self.aggro_shape, 0)
    self.aggro_fixture:setFilterData(ENTITY_CATEGORIES.scan_box, ENTITY_CATEGORIES.player, 0)
    self.aggro_fixture:setUserData(self)
    self.aggro_fixture:setSensor(true)

    -- create signals for fixtures entering and leaving aggro radius
    entity_system:signal(COLLISION_SIGNAL_TYPES.begin_contact, self.aggro_fixture, self, self.on_aggro_collide)
    entity_system:signal(COLLISION_SIGNAL_TYPES.end_contact, self.aggro_fixture, self, self.on_aggro_leave)

    networking:signal(NETWORK_MESSAGE_TYPES.lerp, self, self.on_lerp)
end

function Enemy:update(dt)

    if self.aggrod_character then
        self.waypoint = self.aggrod_character.position
    else
        self.waypoint = math.zero_vector()
    end

    if math.distance_two_points(self.waypoint, math.zero_vector()) > 1 and (math.distance_two_points(self.position, self.waypoint) - self.size / 2) > 300 then
        -- TODO: Make this into a re-usable function
        --       for moving a body, towards another position.
        local angle = math.rad_between_two_points(self.position, self.waypoint)
        local direction_x = math.cos(angle)

        self.body:setLinearVelocity(self.speed * direction_x, 0)
    else
        if self.aggrod_character then
            if self.last_shot_time <= 0 then
                local direction = math.rad_between_two_points(self.position, self.aggrod_character.position)
                local position_x = math.floor(self.position.x + (math.cos(direction) * (self.size)))
                local position_y = math.floor(self.position.y + (math.sin(direction) * (self.size)))
                self.shoot_projectile:shoot(direction, position_x, position_y)
                self.last_shot_time = self.shoot_rpm
            end
        end
    end

    if self.body:getX() < 0 then
        self.body:setPosition(0, self.body:getY())
    end

    if self.last_shot_time > 0 then
        self.last_shot_time = self.last_shot_time - dt
    end

    self.position = { x = self.body:getX(), y = self.body:getY() }
end

function Enemy:draw()
    love.graphics.setColor(1,0,0,1)
    love.graphics.polygon('line', self.body:getWorldPoints(self.shape:getPoints()))

    love.graphics.circle('line', self.body:getX(), self.body:getY(), self.aggro_radius)
end

function Enemy:on_collide(fixture)

end

function Enemy:on_aggro_collide(fixture)
    local data = fixture:getUserData()

    if not data or not data.groups['Player'] then
        return
    end
    if not self.aggrod_character then
        self.aggrod_character = data
    end
end

function Enemy:on_aggro_leave(fixture)
    local data = fixture:getUserData()

    if not data or not data.groups['Player'] then
        return
    end

   if self.aggrod_character.id == data.id then
    self.aggrod_character = nil
   end

end

return Enemy