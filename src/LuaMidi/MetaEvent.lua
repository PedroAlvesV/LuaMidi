local Constants = require('LuaMidi.Constants')
local Util = require('LuaMidi.Util')

local MetaEvent = {}

function MetaEvent.new(fields)
   local self = {
      type = 'meta'
   }
   local data = Util.num_to_var_length(0x00)
   data[#data+1] = Constants.META_EVENT_ID
   data[#data+1] = fields.data
   self.data = data
   return setmetatable(self, { __index = MetaEvent })
end

return MetaEvent