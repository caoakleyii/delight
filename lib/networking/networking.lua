local Connect = require 'lib.networking.messages.connect'
local PlayerJoined = require 'lib.networking.messages.player_joined'
local PlayerInputs = require 'lib.networking.messages.player_inputs'
local PlayerInputRelease = require 'lib.networking.messages.player_input_release'
local Lerp = require 'lib.networking.messages.lerp'
local AiAction = require 'lib.networking.messages.ai_action'
local AiSpawned = require 'lib.networking.messages.ai_spawned'
local NETWORK_MESSAGE_TYPES = require 'lib.types.network_message_types'
local NETWORK_MESSAGE_TYPES_INVERTED = require 'lib.types.network_message_types_inverted'
local Networking = {}

function Networking:new()
    local networking = {}
    networking.message_services = {
        [NETWORK_MESSAGE_TYPES.connect] = Connect:new(),
        [NETWORK_MESSAGE_TYPES.player_joined] = PlayerJoined:new(),
        [NETWORK_MESSAGE_TYPES.player_inputs] = PlayerInputs:new(),
        [NETWORK_MESSAGE_TYPES.player_input_release] = PlayerInputRelease:new(),
        [NETWORK_MESSAGE_TYPES.lerp] = Lerp:new(),
        [NETWORK_MESSAGE_TYPES.ai_action] = AiAction:new(),
        [NETWORK_MESSAGE_TYPES.ai_spawned] = AiSpawned:new()
    }
    networking.message_signals = {}
    self.__index = self
    return setmetatable(networking, self)
end

function Networking:package(message_type, data)
    return self.message_services[message_type]:package(data)
end

function Networking:unpackage(packaged_data, server_player_id)
    server_player_id = server_player_id or 0
    local message_type = love.data.unpack('b', packaged_data:sub(1,1))
    local data = self.message_services[message_type]:unpackage(packaged_data)

    local signal = self.message_signals[message_type .. '#' .. data.id]
    if not signal then
        print('No Signal found for ' .. NETWORK_MESSAGE_TYPES_INVERTED[message_type] .. ' with node id ' .. data.id)
        return
    end
    signal.callback(signal.instance, data, server_player_id)
end

function Networking:signal(message_type, instance, callback)
    self.message_signals[message_type .. '#' .. instance.id] = { instance = instance, callback = callback }
end


networking = Networking:new()