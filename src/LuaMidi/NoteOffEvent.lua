-------------------------------------------------
-- Abstraction of MIDI Note Off Event representation
-- <p>**Note:** This object should not be created
-- by the user.
--
-- @classmod NoteOffEvent
-- @author Pedro Alves
-- @license MIT
-- @see NoteEvent
-------------------------------------------------
local NoteOffEvent = {}

-------------------------------------------------
-- Creates a new NoteOffEvent
--
-- @param fields a table containing the a data field
--
-- @return 	new NoteOffEvent object
-------------------------------------------------
function NoteOffEvent.new(fields)
   local self = {
      data = fields.data
   }
   return setmetatable(self, { __index = NoteOffEvent })
end

return NoteOffEvent
