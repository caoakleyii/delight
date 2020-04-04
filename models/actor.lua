
local NETWORK_MESSAGE_TYPES = require 'lib.types.network_message_types'

local Actor = {}

function Actor:new()
    local actor = {}
    self.__index = self
    return setmetatable(actor, self)
end


function Actor:lerp()
    if server then
        local xv, yv = self.body:getLinearVelocity()
        server:broadcast(NETWORK_MESSAGE_TYPES.lerp, self.id, {
            position = {
                x = self.position.x,
                y = self.position.y
            },
            velocity= {
                x = xv,
                y = yv
            }
        })
    end
end


function Actor:on_lerp(data)
    local x = math.lerp_value(self.position.x, data.position.x, 0.6)
    local y = math.lerp_value(self.position.y, data.position.y, 0.6)
    self.body:setPosition(x, y)
    self.body:setLinearVelocity(data.velocity.x, data.velocity.y)
end

return Actor