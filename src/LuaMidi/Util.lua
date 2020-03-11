-------------------------------------------------
-- Util functions for LuaMidi classes
-- 
-- @module Util
-- @author Pedro Alves Valentim
-- @license MIT
-- @see LuaMidi
-------------------------------------------------

local Constants = require('LuaMidi.Constants')

local utf8 = utf8 or {}
local bitwise = bit32 or nil

if _VERSION <= "Lua 5.2" then
   utf8.len = require('LuaMidi.utf8').len
   if _VERSION == "Lua 5.1" then
      bitwise = require('LuaMidi.bit.numberlua')
   end
else
   bitwise = require('LuaMidi.bit.native_bitwise')
end

local band = bitwise.band
local bor = bitwise.bor
local lshift = bitwise.lshift
local rshift = bitwise.rshift

local Util = {}
Util.bitwise = bitwise

function Util.string_to_bytes(string)
   local bytes = {}
   for i=1, utf8.len(string) do
      bytes[i]=string:byte(i)
   end
   return bytes
end

function Util.is_number(n)
   return tonumber(n) ~= nil
end

function Util.get_pitch(pitch)
   if Util.is_number(pitch) then
      if pitch >= 0 and pitch <= 127 then
         return pitch
      end
      return false
   end
   pitch = string.upper(pitch:sub(1,1))..pitch:sub(2)
   return Constants.NOTES[pitch]
end

function Util.num_to_var_length(ticks)
   local buffer = band(ticks, 0x7F)
   while rshift(ticks, 7) > 0 do
      ticks = rshift(ticks, 7)
      buffer = lshift(buffer, 8)
      buffer = bor(buffer, bor(band(ticks, 0x7F), 0x80))
   end
   local buffer_list = {}
   while true do
      buffer_list[#buffer_list+1] = band(buffer, 0xFF)
      if band(buffer, 0x80) > 0 then
         buffer = rshift(buffer, 8)
      else
         break
      end
   end
   return buffer_list
end

function Util.convert_base(number, base)
   if not number then return number end
   if number == tonumber(number) then
      number = math.floor(number)
   end
   if not base or base == 10 then
      return tostring(number)
   end
   local digits = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
   local t = {}
   local sign = ""
   if tonumber(number) < 0 then
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
   local hex, res = ""
   for _, byte in ipairs(bytes) do
      res = tostring(Util.convert_base(byte, 16))
      if #res == 1 then
         res = "0"..res
      end
      hex = hex..res
   end
   return tonumber(hex, 16)
end

function Util.number_to_bytes(number, bytes_needed)
   bytes_needed = bytes_needed or 1
   local hex_string = tostring(Util.convert_base(number, 16))
   if band(#hex_string, 1) > 0 then
      hex_string = "0"..hex_string
   end
   local hex_array = {}
   while #hex_string > 0 do
      table.insert(hex_array, hex_string:sub(1,2))
      hex_string = hex_string:sub(3)
   end
   for i, elem in ipairs(hex_array) do
      hex_array[i] = tonumber(Util.convert_base(tonumber('0x'..elem), 10))
   end
   while #hex_array < bytes_needed do
      table.insert(hex_array, 1, 0)
   end
   return hex_array
end

function Util.table_concat(table1, table2)
   local res = {}
   for i=1,#table1 do
      res[i] = table1[i]
   end
   for i=1,#table2 do
      res[#res+1] = table2[i]
   end
   return res
end

function Util.table_index_of(table, object)
   if type(table) == 'table' then
      for key, value in pairs(table) do
         if object == value then
            return key
         end
      end
      return false
   end
end

function Util.table_invert(table)
   if type(table) == 'table' then
      local new_table = {}
      for key, value in pairs(table) do
        new_table[value] = key
      end
      return new_table
   end
   return false
end

local function round(num)
   if num >= 0 then
      return math.floor(num+.5) 
   end
   return math.ceil(num-.5)
end
Util.round = round

function Util.convert_velocity(v)
   return round(v / 100 * 127)
end

function Util.revert_velocity(v)
   return round(v / 127 * 100)
end

function Util.get_note_off_status(ch)
   return 0x80 + ch - 1
end

function Util.get_note_on_status(ch)
   return 0x90 + ch - 1
end

function Util.is_track_header(bytes)
   return #bytes == 4 and bytes[1] == 0x4D and bytes[2] == 0x54 and bytes[3] == 0x72 and bytes[4] == 0x6B
end

return Util
