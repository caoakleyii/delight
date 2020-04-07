local COLLISION_SIGNAL_TYPES = require 'lib.types.collision_signal_types'
local ENTITY_CATEGORIES = require 'lib.types.entity_categories'
local Projectile = {}

function Projectile:new()
    local projectile = {}
    projectile.id = math.random(0, 4294967295)
    projectile.size = 5
    projectile.original_position = math.zero_vector()
    projectile.position = math.zero_vector()
    projectile.speed = 5 * 100
    projectile.direction = 0
    projectile.distance = 5000
    projectile.collidables_mask = ENTITY_CATEGORIES.everything
    projectile.damage = 10
    self.__index = self
    return setmetatable(projectile, self)
end

function Projectile:load(world)
    self.body = love.physics.newBody(world, self.size / 2, self.size / 2, "dynamic")
    self.shape = love.physics.newCircleShape(self.size)
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.fixture:setDensity(0)
    self.fixture:setFilterData(ENTITY_CATEGORIES.projectile, self.collidables_mask, 0)
    self.body:setPosition(self.position.x, self.position.y)
    self.original_position = { x = self.position.x, y = self.position.y }
    self.angle_x = math.cos(self.direction)
    self.angle_y = math.sin(self.direction)

    entity_system:signal(COLLISION_SIGNAL_TYPES.begin_contact, self.fixture, self, self.on_collision)
end

function Projectile:update(dt)
    local force_x = self.angle_x * self.speed
    local force_y = self.angle_y * self.speed

    self.body:setLinearVelocity(force_x, force_y)
    self.position = { x = self.body:getX(), y = self.body:getY() }

    if math.distance_two_points(self.original_position, self.position) > self.distance then
        self:release()
    end
end

function Projectile:draw()
    love.graphics.circle('line', self.body:getX(), self.body:getY(), self.size)
end

function Projectile:on_collision(fixture)
    local object = fixture:getUserData()

    if not object then
        return
    end

    if object.damage ~= nil then
        object:damage(self.damage)
    end

    self:release()
end

function Projectile:release()
    self.body:destroy()
    self.cleanup = true
end

return Projectile
