local Character = require 'models.character'
local NETWORK_MESSAGE_TYPES = require 'lib.types.network_message_types'
local ENTITY_TYPES = require 'lib.types.entity_types'
local PlayerSpawner = {}

function PlayerSpawner:new()
    local player_spawner = {}
    player_spawner.id = 2
    self.__index = self

    networking:signal(NETWORK_MESSAGE_TYPES.player_joined, player_spawner, self.on_player_joined)
    return setmetatable(player_spawner, self)
end

function PlayerSpawner:player_joined(player)
    local character = Character:new()
    character.name = player.name
    character.position = {
        x = 50,
        y = 50
    }
    character.player = player

    -- send character to everyone, tell local player they're local
    local character_data = {
        id = self.id,
        entity_node_id = character.id,
        character_type = character.type,
        position = character.position,
        name = character.name,
        local_player = true
    }

    server:send_to(player, NETWORK_MESSAGE_TYPES.player_joined, character_data)

    character_data.local_player = false
    server:broadcast_except(player, NETWORK_MESSAGE_TYPES.player_joined, character_data)

    -- tell player about other characters
    for _, c in ipairs(entity_system.characters) do
        server:send_to(player, NETWORK_MESSAGE_TYPES.player_joined, {
            id = self.id,
            entity_node_id = c.id,
            character_type = c.type,
            position = c.position,
            name = c.name,
            local_player = c.local_player
        })
    end

    -- add to entity system
    self:on_player_joined(character_data)
end

function PlayerSpawner:on_player_joined(c)
    local character = Character:new()
    character.id = c.entity_node_id
    character.type = c.character_type
    character.name = c.name
    character.position = {
        x = c.position.x,
        y = c.position.y
    }
    character.local_player = c.local_player
    entity_system:add(ENTITY_TYPES.characters, character)
end

player_spawner = PlayerSpawner:new()
