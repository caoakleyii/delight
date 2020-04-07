local Enemy = require 'models.enemy'
local NETWORK_MESSAGE_TYPES = require 'lib.types.network_message_types'
local ENTITY_TYPES = require 'lib.types.entity_types'
local GLOBAL_NODE_TYPES = require 'lib.types.global_node_tyes'

local AiSpawner = {}

function AiSpawner:new()
    local ai_spawner = {}
    ai_spawner.id = GLOBAL_NODE_TYPES.ai_spawner
    self.__index = self

    networking:signal(NETWORK_MESSAGE_TYPES.ai_spawned, ai_spawner, self.on_ai_spawned)
    return setmetatable(ai_spawner, self)
end

function AiSpawner:spawn_ai(e)
    local enemy = Enemy:new()

    -- send character to everyone, tell local player they're local
    local enemy_data = {
        entity_node_id = enemy.id,
        position = enemy.position,
        waypoint = enemy.waypoint,
        current_health = enemy.current_health,
        max_health = enemy.max_health,
        actions = enemy.actions
    }

    server:broadcast(NETWORK_MESSAGE_TYPES.ai_spawned, self.id, enemy_data)

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
    enemy.current_health = e.current_health
    enemy.max_health = e.max_health
    entity_system:add(ENTITY_TYPES.ai, enemy)
end

ai_spawner = AiSpawner:new()
