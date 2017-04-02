local NoteOnEvent = {}

function NoteOnEvent.new(fields)
   local self = {
      data = fields.data
   }
   return setmetatable(self, { __index = NoteOnEvent })
end

return NoteOnEvent