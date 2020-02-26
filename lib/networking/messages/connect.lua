local NETWORK_MESSAGE_TYPES = require 'lib.types.network_message_types'
local Connect = {}

--- Connect message service.
-- This message services handles the packaging and unpackaging
-- of the network message type connect.
function Connect:new()
    local connect = {}
    self.__index = self
    return setmetatable(connect, self)
end

--- Packs the data into a compressed string.
-- @table data The data to be packaged
-- @treturn string packaged data
function Connect:package(data)
    -- Connect Packet Info
    ---------------------
    -- Connect network message, 6+ Bytes total
    -- 1 Byte Message Type | 4 Bytes Node ID | 1+ Byte(s) Name -- [IF you have any auth, this is where a JWT Token, Auth Token, User Auth could go]
    ---------------------
    local type_byte = love.data.pack('string', 'b', NETWORK_MESSAGE_TYPES.connect)
    local node_id_bytes = love.data.pack('string', 'I', data.id)
    local name_bytes = love.data.pack('string', 'z', data.name)

    -- Byte indicies
    --        1,         2, 3, 4, 5,    6+
    return type_byte .. node_id_bytes .. name_bytes
end

--- Unpacks the compressed data into a table.
-- @string packed_data The packed data to unpackage
-- @treturn table The unpackaged data as a table
function Connect:unpackage(packed_data)
    return {
        id = love.data.unpack('I', packed_data:sub(2,5)),
        name = love.data.unpack('z', packed_data:sub(6, string.len(packed_data)))
    }
end

return Connect