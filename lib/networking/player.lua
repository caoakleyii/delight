local Player = {}
function Player:new()
    local player = {}
    player.id = math.random(0, 4294967295)
    player.name = ''
    player.ip = ''
    player.port = 0
    player.connected = false
    self.__index = self
    return setmetatable(player, self)
end

return Player
