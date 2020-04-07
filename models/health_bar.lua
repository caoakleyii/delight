local HealthBar = {}

function HealthBar:new(actor)
    local health_bar = {}
    health_bar.actor = actor
    health_bar.vertical_padding = 10
    health_bar.thickness = 5
    self.__index = self
    return setmetatable(health_bar, self)
end

function HealthBar:draw()
    love.graphics.setColor(0,0,0,1)
    love.graphics.rectangle('line', self.actor.position.x - self.actor.size / 2, self.actor.position.y - self.actor.size / 2 - self.vertical_padding, self.actor.size, self.thickness)

    love.graphics.setColor(1,0,0,1)
    love.graphics.rectangle('fill', self.actor.position.x - self.actor.size / 2, self.actor.position.y - self.actor.size / 2 - self.vertical_padding, self.actor.current_health / self.actor.max_health * (self.actor.size), self.thickness)
end

return HealthBar
