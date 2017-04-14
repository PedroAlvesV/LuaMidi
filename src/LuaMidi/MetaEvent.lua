local Constants = require('LuaMidi.Constants')
local Util = require('LuaMidi.Util')

local MetaEvent = {}

function MetaEvent.new(fields)
   local data = Util.num_to_var_length(0x00)
   data = Util.table_concat(data, {Constants.META_EVENT_ID})
   data = Util.table_concat(data, fields.data)
   local self = {
      type = 'meta',
      data = data,
   }
   return setmetatable(self, { __index = MetaEvent })
end

return MetaEvent
