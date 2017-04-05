local Constants = require('LuaMidi.Constants')
local Util = require('LuaMidi.Util')

local ProgramChangeEvent = {}

function ProgramChangeEvent.new(fields)
   local data = Util.num_to_var_length(0x00)
   data[#data+1] = Constants.PROGRAM_CHANGE_STATUS
   data[#data+1] = fields.data
   local self = {
      type = 'program',
		data = data,
   }
   return setmetatable(self, { __index = ProgramChangeEvent })
end

return ProgramChangeEvent
