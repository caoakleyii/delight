local socket = require 'socket'
local NETWORK_MESSAGE_TYPES = require 'lib.types.network_message_types'
local GLOBAL_NODE_TYPES = require 'lib.types.global_node_tyes'
local Player = require 'lib.networking.player'
local stringx = require 'packages.pl.stringx'

local Server = {}

function Server:new()
    local server = {}
    server.id = GLOBAL_NODE_TYPES.client_server
    server.port = 8080
    server.address = '*'
    server.players = {}
    server.udp = socket.udp()
    server.running = false

    self.__index = self
    return setmetatable(server, self)
end

function Server:start()
    networking:signal(NETWORK_MESSAGE_TYPES.connect, self, self.on_connect)

    self.udp:settimeout(0)
    self.udp:setsockname(self.address, self.port)
    self.running = true
    print("Server started on ", self.address, self.port)
end

function Server:receive()
    local packaged_data, ip, port = self.udp:receivefrom()
    if not packaged_data or not self.running then
        return
    end

    local player_id = ip .. "|" .. port
    networking:unpackage(packaged_data, player_id)
end

function Server:send_to(player, message_type, node_id, data)
    local packaged_data = networking:package(message_type, node_id, data)
    local success, err = self.udp:sendto(packaged_data, player.ip, player.port)
    if not success then
        print(success, ' ', err)
    end
end

function Server:broadcast(message_type, node_id, data)
    for _, player  in pairs(self.players) do
        self:send_to(player, message_type, node_id, data)
    end
end

function Server:broadcast_except(exception_player, message_type, node_id, data)
    for _, player in pairs(self.players) do
        if player.id ~= exception_player.id then
            self:send_to(player, message_type, node_id, data)
        end
    end
end

function Server:on_connect(data, player_id)
    print(data.name .. " connected at " .. player_id)

    local ip_and_port = stringx.split(player_id, '|')
    local player = Player:new()
    player.ip = ip_and_port[1]
    player.port = ip_and_port[2]
    player.name = data.name
    player.connected = true
    self.players[player_id] = player

    player_spawner:player_joined(player)
end

server = Server:new()