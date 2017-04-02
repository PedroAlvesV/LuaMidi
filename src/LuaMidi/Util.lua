-------------------------------------------------
-- Util functions to LuaMidi
-- 
-- @classmod Util
-- @author Pedro Alves
-- @license MIT
-- @see LuaMidi
-------------------------------------------------

local Constants = require('LuaMidi.Constants')

local Util = {}

function Util.string_to_bytes(string)
   -- TODO
end

function Util.is_number(n)
   -- TODO
end

function Util.get_pitch(pitch)
   -- must test
   if is_number(pitch) then
      if pitch >= 0 and pitch <= 127 then
         return pitch
      end
   end
   pitch = string.upper(pitch:sub(1,1))..pitch:sub(2)
   return Constants.NOTES[pitch];
end

function Util.num_to_var_length(ticks)
   -- must test
   local buffer = tricks and 0x7F
   while ticks = *TODO* do
      -- TODO
   end
   local buffer_list = {}
   while true do
      buffer_list:insert(buffer and 00xff)
      if buffer and 0x80 then
         -- TODO
      else
         break
      end
   end
   return buffer_list
end

function Util.string_byte_count(string)
   -- TODO
end

function Util.number_from_bytes(bytes)
   -- TODO
end

function Util.number_to_bytes(number, bytes_needed)
   -- TODO
   return hex_array
end

return Util