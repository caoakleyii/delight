local Enemy = require 'models.enemy'
local NETWORK_MESSAGE_TYPES = require 'lib.types.network_message_types'
local ENTITY_TYPES = require 'lib.types.entity_types'
local AiSpawner = {}

function AiSpawner:new()
    local ai_spawner = {}
    ai_spawner.id = 3
    self.__index = self

    networking:signal(NETWORK_MESSAGE_TYPES.ai_spawned, ai_spawner, self.on_ai_spawned)
    return setmetatable(ai_spawner, self)
end

function AiSpawner:spawn_ai(e)
    local enemy = Enemy:new()

    -- send character to everyone, tell local player they're local
    local enemy_data = {
        id = self.id,
        entity_node_id = enemy.id,
        position = enemy.position,
        waypoint = enemy.waypoint and enemy.waypoint or enemy.position
    }

    server:broadcast(NETWORK_MESSAGE_TYPES.ai_spawned, enemy_data)

    -- add to entity system
    self:on_ai_spawned(enemy_data)
end

function AiSpawner:on_ai_spawned(e)
    local enemy = Enemy:new()
    enemy.id = e.entity_node_id
    enemy.position = {
        x = e.position.x,
        y = e.position.y
    }
    enemy.waypoint = {
        x = e.waypoint.x,
        y = e.waypoint.y
    }
    entity_system:add(ENTITY_TYPES.ai, enemy)
end

ai_spawner = AiSpawner:new()
