-------------------------------------------------
-- Abstraction of an arbitrary MIDI event
-- <p>**Note:** This object should not be created
-- by the user.
--
-- @classmod ArbitraryEvent
-- @author Pedro Alves Valentim
-- @license MIT
-------------------------------------------------
local ArbitraryEvent = {}

-------------------------------------------------
--- Functions
-- @section functions
-------------------------------------------------

-------------------------------------------------
-- Creates a new ArbitraryEvent
--
-- @param fields a table containing the a data field
--
-- @return 	new ArbitraryEvent object
-------------------------------------------------
function ArbitraryEvent.new(fields)
   local self = { data = fields.data }
   return setmetatable(self, { __index = ArbitraryEvent })
end

return ArbitraryEvent
