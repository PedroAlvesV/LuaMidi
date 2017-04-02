local ProgramChangeEvent = {}

function ProgramChangeEvent.new(fields)
   local self = {
      type = 'program',
      data = Util.num_to_var_length(0x00),
   }
   self.data = -- TODO
   return setmetatable(self, { __index = ProgramChangeEvent })
end

return ProgramChangeEvent