local EntitySystem = {}

function EntitySystem:new()
    local entity_system = {}
    entity_system.world = love.physics.newWorld(0,0, true)
    entity_system.characters = {}
    entity_system.ai = {}

    self.__index = self
    return setmetatable(entity_system, self)
end

function EntitySystem:add(entity_type, entity)
    entity:load()
    table.insert(self[entity_type], entity)
end

entity_system = EntitySystem:new()