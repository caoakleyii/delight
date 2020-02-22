local NETWORK_MESSAGE_TYPES = require 'lib.types.network_message_types'
local Connect = {}

function Connect:new()
    local connect = {}
    self.__index = self
    return setmetatable(connect, self)
end

function Connect:package(data)
    -- CONNECT PACKET INFO
    ---------------------
    -- Connect network message, 1+ Byte total
    -- 1 byte MESSAGE_TYPE | [IF you have any auth, this is where a JWT Token, Auth Token, User GUID would go]
    -- char
    ---------------------
    local type_byte = love.data.pack('string', 'b', NETWORK_MESSAGE_TYPES.connect)
    local node_id_bytes = love.data.pack('string', 'I', data.id)
    local name_bytes = love.data.pack('string', 'z', data.name)

    -- lua is fucking weird and has 1 based indexes for everything.
    -- wtf i know
    --        1,         2, 3, 4, 5,    6+
    return type_byte .. node_id_bytes .. name_bytes
end

function Connect:unpackage(packed_data)
    return {
        id = love.data.unpack('I', packed_data:sub(2,5)),
        name = love.data.unpack('z', packed_data:sub(6, string.len(packed_data)))
    }
end

return Connect