local Util = require('LuaMidi.Util')

local MetaEvent = {}

function MetaEvent.new(fields)
   local self = {
      type = 'meta',
      data = Util.num_to_var_length(0x00),
   }
   self.data = -- TODO
   return setmetatable(self, { __index = MetaEvent })
end

return MetaEvent