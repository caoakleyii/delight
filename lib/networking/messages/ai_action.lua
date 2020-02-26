local NETWORK_MESSAGE_TYPES = require 'lib.types.network_message_types'
local AiAction = {}

--- AiAction message service.
-- This message services handles the packaging and unpackaging
-- of the network message type ai_aciton.
function AiAction:new()
    local ai_action = {}

    self.__index = self
    return setmetatable(ai_action, self)
end

--- Packs the data into a compressed string.
-- @table data The data to be packaged
-- @treturn string packaged data
function AiAction:package(data)
    -- Ai Action Packet Info
    ---------------------
    -- Ai Action network message, 8 Byte total
    -- 1 Byte Message Type | 4 Bytes Node ID | 2 Bytes Action Type | 1+ Byte String Meta Data
    ---------------------
    local type_byte = love.data.pack('string', 'b', NETWORK_MESSAGE_TYPES.ai_action)
    local node_id_bytes = love.data.pack('string', 'I', data.id)
    local action_type_bytes = love.data.pack('string', 'H', data.action_type)
    local action_meta_data_bytes = love.data.pack('string', 'z', data.action_meta_data)

    -- Byte indicies
    --        1,         2, 3, 4, 5,            6,7                8+
    return type_byte .. node_id_bytes .. action_type_bytes .. action_meta_data_bytes
end

--- Unpacks the compressed data into a table.
-- @string packed_data The packed data to unpackage
-- @treturn table The unpackaged data as a table
function AiAction:unpackage(packed_data)
    return {
        id = love.data.unpack('I', packed_data:sub(2,5)),
        action_type = love.data.unpack('H', packed_data:sub(6,7)),
        action_meta_data = love.data.unpack('z', packed_data:sub(8, string.len(packed_data)))
    }
end

return AiAction

