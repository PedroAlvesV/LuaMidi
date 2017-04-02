local NoteOffEvent = {}

function NoteOffEvent.new(fields)
   local self = {
      data = fields.data
   }
   return setmetatable(self, { __index = NoteOffEvent })
end

return NoteOffEvent