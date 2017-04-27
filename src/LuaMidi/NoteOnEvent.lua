-------------------------------------------------
-- Abstraction of MIDI Note On Event representation
-- <p>**Note:** This object should not be created
-- by the user.
--
-- @classmod NoteOnEvent
-- @author Pedro Alves
-- @license MIT
-- @see NoteEvent
-------------------------------------------------
local NoteOnEvent = {}

-------------------------------------------------
-- Creates a new NoteOnEvent
--
-- @param fields a table containing the a data field
--
-- @return 	new NoteOnEvent object
-------------------------------------------------
function NoteOnEvent.new(fields)
   local self = {
      data = fields.data
   }
   return setmetatable(self, { __index = NoteOnEvent })
end

return NoteOnEvent
