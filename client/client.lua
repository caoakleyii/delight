local socket = require 'socket'
local NETWORK_MESSAGE_TYPES = require 'lib.types.network_message_types'
local Client = {}
require 'lib.networking.networking'

function Client:new()
    local client = {}
    client.id = 1 -- Should be same Node ID as Server
    client.server_address = 'localhost'
    client.server_port = 8080
    client.udp = socket.udp()
    client.players = {}
    client.connected = false
    self.__index = self
    return setmetatable(client, self)
end

function Client:connect()
    networking:signal(NETWORK_MESSAGE_TYPES.player_joined, self, self.on_player_joined)
    self.udp:settimeout(0)
    self.udp:setpeername(self.server_address, self.server_port)
    self:send(NETWORK_MESSAGE_TYPES.connect, { id = self.id, name = 'Cervial' })
    self.connect = true
end

function Client:disconnect()
    if not self.connected then
        return
    end

    self:send(NETWORK_MESSAGE_TYPES.disconnect, nil)
    self.udp:close()
    self.connected = false
end

function Client:send(message_type, data)
    local packaged_data = networking:package(message_type, data)
    self.udp:send(packaged_data)
end

function Client:receive()
    local packaged_data = self.udp:receive()
    if not packaged_data then
        return
    end

    networking:unpackage(packaged_data)
end

client = Client:new()