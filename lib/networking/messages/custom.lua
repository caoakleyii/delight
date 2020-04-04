local NETWORK_MESSAGE_TYPES = require 'lib.types.network_message_types'
local Custom = {}
local DATA_TYPE_SIZES = {
    b = 1,
    B = 1,
    h = 2,
    H = 2,
    l = 8,
    L = 8,
    i = 4,
    I = 4,
    f = 4,
    d = 8,
    z = 1
}
--- Custom message service.
-- This message services handles the packaging and unpackaging
-- of the network message type custom.
function Custom:new()
    local custom = {}
    self.__index = self
    return setmetatable(custom, self)
end

--- Packs the data into a compressed string.
-- @table data The data to be packaged
-- @treturn string packaged data
function Custom:package(node_id, custom_data)
    -- Custom Packet Info
    ---------------------
    -- Custom network message, 6+ Bytes total
    -- 1 Byte Message Type | 4 Bytes Node ID | 1+ Byte(s) Name -- [IF you have any auth, this is where a JWT Token, Auth Token, User Auth could go]
    ---------------------
    local type_byte = love.data.pack('string', 'b', NETWORK_MESSAGE_TYPES.custom)
    local node_id_bytes = love.data.pack('string', 'I', node_id)
    local packed_data = type_byte .. node_id_bytes

    for _, v in ipairs(custom_data) do
        local bytes = love.data.pack('string', v.data_type, v.value)
        packed_data = packed_data .. bytes
    end

    return packed_data
end

--- Unpacks the compressed data into a table.
-- @string packed_data The packed data to unpackage
-- @treturn table The unpackaged data as a table
function Custom:unpackage(packed_data, custom_data_byte_structure)
    local data = {
        id = love.data.unpack('I', packed_data:sub(2,5))
    }
    local index = 6
    for _, cdb in ipairs(custom_data_byte_structure) do
        local data_size = cdb.length or DATA_TYPE_SIZES[cdb.data_type]
        local data_type_end_index = index + (data_size - 1)
        local value = love.data.unpack(cdb.data_type, packed_data:sub(index, data_type_end_index))
        data[cdb.key] = value

        index = index + data_size
    end
    return data
end

return Custom