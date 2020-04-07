local NETWORK_MESSAGE_TYPES = require 'lib.types.network_message_types'
local Damage = {}

--- Disconnet message service.
-- This message services handles the packaging and unpackaging
-- of the network message type damage.
function Damage:new()
    local damage = {}
    self.__index = self
    return setmetatable(damage, self)
end

--- Packs the data into a compressed string.
-- @table data The data to be packaged
-- @treturn string packaged data
function Damage:package(node_id, data)
    -- Damage Packet Info
    ---------------------
    -- Connect network message, 6+ Bytes total
    -- 1 Byte Message Type | 4 Bytes Node ID
    ---------------------
    local type_byte = love.data.pack('string', 'b', NETWORK_MESSAGE_TYPES.damage)
    local node_id_bytes = love.data.pack('string', 'I', node_id)
    local damage_amount = love.data.pack('string', 'H', math.floor(data.damage_amount))

    -- Byte indicies
    --        1,         2, 3, 4, 5,        6,7
    return type_byte .. node_id_bytes .. damage_amount
end

--- Unpacks the compressed data into a table.
-- @string packed_data The packed data to unpackage
-- @treturn table The unpackaged data as a table
function Damage:unpackage(packed_data)
    return {
        id = love.data.unpack('I', packed_data:sub(2,5)),
        damage_amount = love.data.unpack('H', packed_data:sub(6,7))
    }
end

return Damage