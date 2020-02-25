local NETWORK_MESSAGE_TYPES = require 'lib.types.network_message_types'
local Character = {}
function Character:new()
    local character = {}
    character.id = math.random(0, 4294967295)
    character.name = ''
    character.position = { x = 0, y = 0 }
    character.type = 1
    character.local_player = false
    character.player = {}
    character.keys_down = {}
    self.__index = self
    return setmetatable(character, self)
end

-- Love2D Events
function Character:load()

    networking:signal(NETWORK_MESSAGE_TYPES.player_inputs, self, self.on_player_inputs)
    networking:signal(NETWORK_MESSAGE_TYPES.player_input_release, self, self.on_player_inputs_release)
    networking:signal(NETWORK_MESSAGE_TYPES.lerp, self, self.on_lerp)

    if self.local_player then
        function love.keypressed(key, scancode, isrepeat)
            if key == "escape" then
                return
            end

            self.keys_down[key] = true
            if not isrepeat then
                -- TODO: update when key mappings become a thing
                -- add check if key is a skill, then we should send angle
                client:send(NETWORK_MESSAGE_TYPES.player_inputs, { id = self.id, key = key })
            end
        end

        function love.keyreleased(key, scancode)
            self.keys_down[key] = nil
            -- TODO: update when key mappings become a thing
            client:send(NETWORK_MESSAGE_TYPES.player_input_release, { id = self.id, key = key })
        end
    end
end

function Character:update(dt)
end

function Character:draw()
end

--  Methods
function Character:lerp()
    if server then
        server:broadcast(NETWORK_MESSAGE_TYPES.lerp, {
            id = self.id,
            position = {
                x = self.position.x,
                y = self.position.y
            }
        })
    end
end


-- SIGNAL EVENTS

function Character:on_player_inputs(data)
    self.keys_down[data.key] = true
    if server then
        server:broadcast_except(self.player, NETWORK_MESSAGE_TYPES.player_inputs, data)
    end
end

function Character:on_player_inputs_release(data)
    self.keys_down[data.key] = nil
    if server then
        server:broadcast_except(self.player, NETWORK_MESSAGE_TYPES.player_input_release, data)
    end
end

function Character:on_lerp(data)
    self.position.x = data.position.x
    self.position.y = data.position.y
end

return Character