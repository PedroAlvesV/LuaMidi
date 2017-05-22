-------------------------------------------------
-- Abstraction of MIDI Program Change Event
--
-- @classmod ProgramChangeEvent
-- @author Pedro Alves
-- @license MIT
-------------------------------------------------

local Constants = require('LuaMidi.Constants')
local Util = require('LuaMidi.Util')

local ProgramChangeEvent = {}

-------------------------------------------------
-- Creates a new ProgramChangeEvent to change the
-- track's instrument
--
-- @param pcnumber a valid MIDI patch change number
--
-- @return 	new ProgramChangeEvent object
-------------------------------------------------
function ProgramChangeEvent.new(pcnumber)
   local self = {
      type = 'program-change',
      data = { 0x00, Constants.PROGRAM_CHANGE_STATUS, pcnumber },
   }
   return setmetatable(self, { __index = ProgramChangeEvent })
end

-------------------------------------------------
-- Prints event's data in a human-friendly style
-------------------------------------------------
function ProgramChangeEvent:print()
   print("\nClass / Type:\tProgramChangeEvent / '"..self.type.."'")
   print("Data:\t", self.data[3])
end

-------------------------------------------------
-- Sets ProgramChangeEvent's value
--
-- @number value event's new value
--
-- @return 	event with new value
-------------------------------------------------
function ProgramChangeEvent:set_value(value)
   if type(value) ~= 'number' then return false end
   self.data[3] = value
   return self
end

-------------------------------------------------
-- Gets ProgramChangeEvent's value
--
-- @return 	event's value
-------------------------------------------------
function ProgramChangeEvent:get_value()
   return self.data[3]
end

return ProgramChangeEvent
