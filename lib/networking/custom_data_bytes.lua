local NETWORKING_DATA_TYPES = require 'lib.types.networking_data_types'

local CustomDataBytes = {}
function CustomDataBytes:new(cdb)
    local custom_data_bytes = {}
    custom_data_bytes.key = ''
    custom_data_bytes.data_type = NETWORKING_DATA_TYPES.signed_byte
    custom_data_bytes.value = nil
    custom_data_bytes.length = nil
    table.merge(custom_data_bytes, cdb)
    self.__index = self
    return setmetatable(custom_data_bytes, self)
end

return CustomDataBytes