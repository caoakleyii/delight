local NETWORK_MESSAGE_TYPES = require 'lib.types.network_message_types'
local Destroy = {}

--- Disconnet message service.
-- This message services handles the packaging and unpackaging
-- of the network message type destroy.
function Destroy:new()
    local destroy = {}
    self.__index = self
    return setmetatable(destroy, self)
end

--- Packs the data into a compressed string.
-- @table data The data to be packaged
-- @treturn string packaged data
function Destroy:package(node_id, data)
    -- Destroy Packet Info
    ---------------------
    -- Connect network message, 6+ Bytes total
    -- 1 Byte Message Type | 4 Bytes Node ID
    ---------------------
    local type_byte = love.data.pack('string', 'b', NETWORK_MESSAGE_TYPES.destroy)
    local node_id_bytes = love.data.pack('string', 'I', node_id)

    -- Byte indicies
    --        1,         2, 3, 4, 5,
    return type_byte .. node_id_bytes
end

--- Unpacks the compressed data into a table.
-- @string packed_data The packed data to unpackage
-- @treturn table The unpackaged data as a table
function Destroy:unpackage(packed_data)
    return {
        id = love.data.unpack('I', packed_data:sub(2,5))
    }
end

return Destroy