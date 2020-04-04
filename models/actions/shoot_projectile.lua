local CustomDataBytes = require 'lib.networking.custom_data_bytes'
local Projectile = require 'models.projectile'

local NETWORK_MESSAGE_TYPES = require 'lib.types.network_message_types'
local NETWORK_DATA_TYPES = require 'lib.types.networking_data_types'
local ENTITY_TYPES = require 'lib.types.entity_types'
local GLOBAL_NODE_TYPES = require 'lib.types.global_node_tyes'

local ShootProjectile = {}

function ShootProjectile:new()
    local shoot_projectile = {}
    shoot_projectile.id = GLOBAL_NODE_TYPES.projectile_shoot_action
    shoot_projectile.custom_message_structure = {
        CustomDataBytes:new({
            key = 'direction',
            data_type = NETWORK_DATA_TYPES.double
        }),
        CustomDataBytes:new({
            key = 'position_x',
            data_type = NETWORK_DATA_TYPES.unsigned_short
        }),
        CustomDataBytes:new({
            key = 'position_y',
            data_type = NETWORK_DATA_TYPES.double
        })
    }

    networking:signal(NETWORK_MESSAGE_TYPES.custom, shoot_projectile, self.on_shoot, shoot_projectile.custom_message_structure)

    self.__index = self
    return setmetatable(shoot_projectile, self)
end


function ShootProjectile:shoot(direction, position_x, position_y)

    if server then
        server:broadcast(NETWORK_MESSAGE_TYPES.custom, self.id, {
            CustomDataBytes:new({
                key = 'direction',
                data_type = NETWORK_DATA_TYPES.double,
                value = direction
            }),
            CustomDataBytes:new({
                key = 'position_x',
                data_type = NETWORK_DATA_TYPES.unsigned_short,
                value = position_x
            }),
            CustomDataBytes:new({
                key = 'position_y',
                data_type = NETWORK_DATA_TYPES.double,
                value = position_y
            })
        })

        local projectile = Projectile:new()
        projectile.direction = direction
        projectile.position =  {
            x = position_x,
            y = position_y
        }
        entity_system:add(ENTITY_TYPES.objects, projectile)
    end
end

function ShootProjectile:on_shoot(data)
    local projectile = Projectile:new()
    projectile.direction = data.direction
    projectile.position =  {
        x = data.position_x,
        y = data.position_y
    }
    entity_system:add(ENTITY_TYPES.objects, projectile)
end

return ShootProjectile

