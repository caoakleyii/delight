local NETWORK_MESSAGE_TYPES = require 'lib.types.network_message_types'
local AiSpawned = {}

--- AiSpawned message service.
-- This message services handles the packaging and unpackaging
-- of the network message type ai_spawned.
function AiSpawned:new()
    local ai_spawned = {}
    self.__index = self
    return setmetatable(ai_spawned, self)
end

--- Packs the data into a compressed string.
-- @table data The data to be packaged
-- @treturn string packaged data
function AiSpawned:package(node_id, data)
    -- AI Spawned Packet Info
    ---------------------
    -- AI Spawned network message,  17 Bytes total
    -- 1 Byte Message Type | 4 Bytes Node ID | 4 Bytes Entity Node Id | 2 Bytes Entity X | 2 Bytes Entity Y | 2 Bytes Waypoint X | 2 Bytes Waypoint Y
    ---------------------

    local type_byte = love.data.pack('string', 'b', NETWORK_MESSAGE_TYPES.ai_spawned)
    local node_id_bytes = love.data.pack('string', 'I', node_id)
    local entity_node_id_byte = love.data.pack('string', 'I', data.entity_node_id)
    local entity_x_bytes = love.data.pack('string', 'H', math.floor(data.position.x))
    local entity_y_bytes = love.data.pack('string', 'H', math.floor(data.position.y))
    local waypoint_x_bytes = love.data.pack('string', 'H', math.floor(data.waypoint.x))
    local waypoint_y_bytes = love.data.pack('string', 'H', math.floor(data.waypoint.y))
    local current_health = love.data.pack('string', 'H', math.floor(data.current_health))
    local max_health = love.data.pack('string', 'H', math.floor(data.max_health))

    -- Bytes Indicies
    --        1,           2, 3, 4, 5,          6,7,8,9              10, 11          12,13              14,15               16, 17              18,19           20,21
    return type_byte .. node_id_bytes .. entity_node_id_byte .. entity_x_bytes .. entity_y_bytes .. waypoint_x_bytes .. waypoint_y_bytes .. current_health .. max_health
end

--- Unpacks the compressed data into a table.
-- @string packed_data The packed data to unpackage
-- @treturn table The unpackaged data as a table
function AiSpawned:unpackage(packed_data)
    return {
        id = love.data.unpack('I', packed_data:sub(2, 5)),
        entity_node_id = love.data.unpack('I', packed_data:sub(6, 9)),
        position = {
            x = love.data.unpack('H', packed_data:sub(10, 11)),
            y = love.data.unpack('H', packed_data:sub(12, 13))
        },
        waypoint = {
            x = love.data.unpack('H', packed_data:sub(14, 15)),
            y = love.data.unpack('H', packed_data:sub(16, 17))
        },
        current_health = love.data.unpack('H', packed_data:sub(18,19)),
        max_health = love.data.unpack('H', packed_data:sub(20,21))
    }
end

return AiSpawned