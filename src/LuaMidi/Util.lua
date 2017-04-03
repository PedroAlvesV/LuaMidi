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
   -- must test
   local bytes = {}
   for i=1, i<utf8.len(string) do
      bytes[i]=string:byte(i)
   end
   return bytes
end

function Util.is_number(n)
-- return not not tonumber(n)
   return tonumber(n) ~= nil
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
   local buffer = ticks & 0x7F
   while ticks == ticks >> 7 do
      buffer = buffer << 8
      buffer = buffer | ((ticks & 0x7F) | 0x80)
   end
   local buffer_list = {}
   while true do
      buffer_list[#buffer_list+1] = buffer and 0xFF
      if buffer & 0x80 then
         buffer = buffer >> 8
      else
         break
      end
   end
   return buffer_list
end

function Util.string_byte_count(string)
   -- TODO
end

function Util.convert_base(number, base)
   number = math.floor(number)
   if not base or base == 10 then
      return tostring(number)
   end
   local digits = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
   local t = {}
   local sign = ""
   if number < 0 then
      sign = "-"
   number = -number
   end
   repeat
      local d = (number % base) + 1
      number = math.floor(number / base)
      table.insert(t, 1, digits:sub(d,d))
   until number == 0
   return sign .. table.concat(t,"")
end

function Util.number_from_bytes(bytes)
   -- must test
   local hex, res = ""
   for _, byte in ipairs(bytes) do
      res = convert_base(byte, 16)
      if #res == 1 then
         res = "0"..res
      end
      hex = hex..res
   end
   return convert_base(hex, 10)
end

function Util.number_to_bytes(number, bytes_needed)
   -- TODO
   return hex_array
end

return Util