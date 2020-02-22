require ('lib.extensions.table')
local network_message_types = require 'lib.types.network_message_types'
return table.Invert(network_message_types)
