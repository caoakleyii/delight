local NETWORK_MESSAGE_TYPES = require 'lib.types.network_message_types'
local PlayerAngle = {}

--- PlayerInputs message service.
-- This message services handles the packaging and unpackaging
-- of the network message type player_angle.
function PlayerAngle:new()
    local player_angle = {}
    self.__index = self
    return setmetatable(player_angle, self)
end

--- Packs the data into a compressed string.
-- @table data The data to be packaged
-- @treturn string packaged data
function PlayerAngle:package(node_id, data)
    -- Player Inputs Packet Info
    ---------------------
    -- Player Inputs network message, 10+ Byte total
    -- 1 Byte Message Type | 4 Bytes Node ID | 4 Bytes Aim Angle | 1+ Byte Key
    ---------------------
    local type_byte = love.data.pack('string', 'b', NETWORK_MESSAGE_TYPES.player_angle)
    local node_id_bytes = love.data.pack('string', 'I', node_id)
    local aim_angle_bytes = love.data.pack('string', 'f', data.aim_angle)

    -- Byte indicies
    --        1,         2, 3, 4, 5,        6,7,8,9
    return type_byte .. node_id_bytes .. aim_angle_bytes
end

--- Unpacks the compressed data into a table.
-- @string packed_data The packed data to unpackage
-- @treturn table The unpackaged data as a table
function PlayerAngle:unpackage(packed_data)
    return {
        id = love.data.unpack('I', packed_data:sub(2,5)),
        aim_angle = love.data.unpack('f', packed_data:sub(6,9))
    }
end

return PlayerAngle