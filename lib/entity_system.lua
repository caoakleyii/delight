local COLLISION_SIGNAL_TYPES = require 'lib.types.collision_signal_types'
local EntitySystem = {}

function EntitySystem:new()
    local entity_system = {}
    entity_system.world = love.physics.newWorld(0, 0, true)
    entity_system.world:setCallbacks(self.begin_contact, self.end_contact, self.pre_solve, self.post_solve)
    entity_system.characters = {}
    entity_system.ai = {}
    entity_system.signals = {}

    self.__index = self
    return setmetatable(entity_system, self)
end

function EntitySystem:add(entity_type, entity)
    entity:load(self.world)
    table.insert(self[entity_type], entity)
end

function EntitySystem:signal(signal_type, instance, callback)
    self.signals[signal_type .. '#' .. instance.id] = { instance = instance, callback = callback }
end

function EntitySystem:world_collision_callback(callback_type, a, b,  collision)
    local a_signal = self.signals[callback_type .. '#' .. a:getUserData().id]
    local b_signal = self.signals[callback_type .. '#' .. b:getUserData().id]

    if a_signal then
        a_signal.callback(a_signal.instance, b, collision)
    end

    if b_signal then
        b_signal.callback(b_signal.instance, a, collision)
    end

end

function EntitySystem.begin_contact(a, b, collision)
    entity_system:world_collision_callback(COLLISION_SIGNAL_TYPES.begin_contact, a, b, collision)
end

function EntitySystem.end_contact(a, b, collision)
    entity_system:world_collision_callback(COLLISION_SIGNAL_TYPES.end_contact, a, b, collision)
end

function EntitySystem.pre_solve(a, b, collision)
    entity_system:world_collision_callback(COLLISION_SIGNAL_TYPES.pre_solve, a, b, collision)
end

function EntitySystem.post_solve(a, b, collision)
    entity_system:world_collision_callback(COLLISION_SIGNAL_TYPES.post_solve, a, b, collision)
end

entity_system = EntitySystem:new()