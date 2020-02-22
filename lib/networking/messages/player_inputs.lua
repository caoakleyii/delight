local NETWORK_MESSAGE_TYPES = require 'lib.types.network_message_types'
local PlayerInputs = {}

function PlayerInputs:new()
    local player_inputs = {}
    self.__index = self
    return setmetatable(player_inputs, self)
end

function PlayerInputs:package(data)
    -- Player Inputs PACKET INFO
    ---------------------
    -- Player Inputs network message, 6 Byte total
    -- 1 byte MESSAGE_TYPE | 4 Bytes Node ID | 1+ Byte Key
    -- char
    ---------------------
    local type_byte = love.data.pack('string', 'b', NETWORK_MESSAGE_TYPES.player_inputs)
    local node_id_bytes = love.data.pack('string', 'I', data.id)
    local key_bytes = love.data.pack('string', 'z', data.key)

    -- lua is fucking weird and has 1 based indexes for everything.
    -- wtf i know
    --        1,         2, 3, 4, 5,    6
    return type_byte .. node_id_bytes .. key_bytes
end

function PlayerInputs:unpackage(packed_data)
    return {
        id = love.data.unpack('I', packed_data:sub(2,5)),
        key = love.data.unpack('z', packed_data:sub(6, string.len(packed_data)))
    }
end

return PlayerInputs