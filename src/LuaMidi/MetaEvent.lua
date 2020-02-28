-------------------------------------------------
-- Abstraction of MIDI Meta Event representation
-- <p>**Note:** This object should not be created
-- by the user.
--
-- @classmod MetaEvent
-- @author Pedro Alves Valentim
-- @license MIT
-------------------------------------------------

local Constants = require('LuaMidi.Constants')
local Util = require('LuaMidi.Util')

local MetaEvent = {}

-------------------------------------------------
--- Functions
-- @section functions
-------------------------------------------------

-------------------------------------------------
-- Creates a new MetaEvent
--
-- @param fields a table containing the MetaEvent's data in a data field
--
-- @return 	new MetaEvent object
-------------------------------------------------
function MetaEvent.new(fields)
   local data = Util.num_to_var_length(0x00)
   data = Util.table_concat(data, {Constants.META_EVENT_ID})
   data = Util.table_concat(data, fields.data)
   local self = {
      type = 'meta',
      data = data,
   }
   return setmetatable(self, { __index = MetaEvent })
end

-------------------------------------------------
--- Methods
-- @section methods
-------------------------------------------------

-------------------------------------------------
-- Prints event's data in a human-friendly style
-------------------------------------------------
function MetaEvent:print()
   local printable_data = ""
   if Util.table_index_of(Constants.METADATA_TYPES, self.subtype) < 0x08 then
      for j=5, #self.data do
         printable_data = printable_data..string.char(self.data[j])
      end
      printable_data = '"'..printable_data..'"'
      if self.subtype ~= "Instrument" then
         printable_data =  '\t'..printable_data
      end
   elseif self.subtype == "Tempo" then
      local data_bytes = {self.data[5], self.data[6], self.data[7]}
      local ms = Util.number_from_bytes(data_bytes)
      local bpm = Util.round(60000000/ms)
      printable_data = "\t"..bpm.." bpm"
   elseif self.subtype == "Time Signature" then
      printable_data = self.data[5]
      printable_data = printable_data.."/"..math.ceil(2^self.data[6])
   elseif self.subtype == "Key Signature" then
      local majmin = {'major', 'minor'}
      local keys = {{'C','A'},{'G','E'},{'D','B'},{'A','F#'},
         {'E','C#'},{'B','G#'},{'F#','D#'},{'C#','A#'}}
      local sharps_num = tostring(self.data[5])
      printable_data = sharps_num.."#"
      printable_data = printable_data.." ("..keys[sharps_num+1][self.data[6]+1].." "..majmin[self.data[6]+1]..")"
   end
   print("\nClass / Type:\tMetaEvent / '"..self.type.."'")
   print(self.subtype..":", printable_data)
end

return MetaEvent
