local NETWORK_MESSAGE_TYPES = require 'lib.types.network_message_types'
local Lerp = {}

function Lerp:new()
    local player_inputs = {}
    self.__index = self
    return setmetatable(player_inputs, self)
end

function Lerp:package(data)
    -- Player Inputs PACKET INFO
    ---------------------
    -- Player Inputs network message, 9 Byte total
    -- 1 byte MESSAGE_TYPE | 4 Bytes Node ID | 1+ Byte Key
    -- char
    ---------------------
    local type_byte = love.data.pack('string', 'b', NETWORK_MESSAGE_TYPES.lerp)
    local node_id_bytes = love.data.pack('string', 'I', data.id)
    local position_x_bytes = love.data.pack('string', 'H', math.floor(data.position.x))
    local position_y_bytes = love.data.pack('string', 'H', math.floor(data.position.y))

    -- lua is fucking weird and has 1 based indexes for everything.
    -- wtf i know
    --        1,         2, 3, 4, 5,            6,7                8, 9
    return type_byte .. node_id_bytes .. position_x_bytes .. position_y_bytes
end

function Lerp:unpackage(packed_data)
    return {
        id = love.data.unpack('I', packed_data:sub(2,5)),
        position = {
          x = love.data.unpack('H', packed_data:sub(6, 7)),
          y = love.data.unpack('H', packed_data:sub(8, 9))
        }
    }
end

return Lerp