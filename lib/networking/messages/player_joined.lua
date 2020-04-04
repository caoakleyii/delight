local NETWORK_MESSAGE_TYPES = require 'lib.types.network_message_types'
local PlayerJoined = {}

--- PlayerJoined message service.
-- This message services handles the packaging and unpackaging
-- of the network message type player_joined.
function PlayerJoined:new()
    local player_joined = {}
    self.__index = self
    return setmetatable(player_joined, self)
end

--- Packs the data into a compressed string.
-- @table data The data to be packaged
-- @treturn string packaged data
function PlayerJoined:package(node_id, data)
    -- Player Joined Packet Info
    ---------------------
    -- Player joined network message,  16+ Bytes total
    -- 1 byte Message Type | 4 byte Node ID | 4 Byte Entity Node ID | 1 Byte Entity Type | 2 Bytes Player X | 2 Bytes Player Y | 1+ Bytes Name
    ---------------------

    local type_byte = love.data.pack('string', 'b', NETWORK_MESSAGE_TYPES.player_joined)
    local node_id_bytes = love.data.pack('string', 'I', node_id)
    local entity_node_id_byte = love.data.pack('string', 'I', data.entity_node_id)
    local character_type_byte = love.data.pack('string', 'b', data.character_type)
    local entity_x_bytes = love.data.pack('string', 'H', math.floor(data.position.x))
    local entity_y_bytes = love.data.pack('string', 'H', math.floor(data.position.y))
    local local_player_byte = love.data.pack('string', 'b', data.local_player and 1 or 0)
    local player_name_bytes = love.data.pack('string', 'z', data.name)


    -- Byte indicies
    --        1,         2, 3, 4, 5,          6,7,8,9,                 10,                  11,12,           13, 14,               15,              16+
    return type_byte .. node_id_bytes .. entity_node_id_byte .. character_type_byte .. entity_x_bytes .. entity_y_bytes .. local_player_byte ..  player_name_bytes
end

--- Unpacks the compressed data into a table.
-- @string packed_data The packed data to unpackage
-- @treturn table The unpackaged data as a table
function PlayerJoined:unpackage(packed_data)
    return {
        id = love.data.unpack('I', packed_data:sub(2, 5)),
        entity_node_id = love.data.unpack('I', packed_data:sub(6, 9)),
        character_type = love.data.unpack('b', packed_data:sub(10, 10)),
        position = {
            x = love.data.unpack('H', packed_data:sub(11, 12)),
            y = love.data.unpack('H', packed_data:sub(13, 14))
        },
        local_player = love.data.unpack('b', packed_data:sub(15, 15)) == 1 and true or false,
        name = love.data.unpack('z', packed_data:sub(16, string.len(packed_data)))
    }
end

return PlayerJoined