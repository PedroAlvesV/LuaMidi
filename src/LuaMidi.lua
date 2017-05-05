-------------------------------------------------
-- LuaMidi Library Class
-- <p>All modules are available through it.
-- 
-- @classmod LuaMidi
-- @author Pedro Alves
-- @license MIT
-------------------------------------------------

local LuaMidi = {}

LuaMidi.Constants = require 'LuaMidi.Constants'
LuaMidi.Chunk = require 'LuaMidi.Chunk'
LuaMidi.MetaEvent = require 'LuaMidi.MetaEvent'
LuaMidi.NoteEvent = require 'LuaMidi.NoteEvent'
LuaMidi.NoteOffEvent = require 'LuaMidi.NoteOffEvent'
LuaMidi.NoteOnEvent = require 'LuaMidi.NoteOnEvent'
LuaMidi.ProgramChangeEvent = require 'LuaMidi.ProgramChangeEvent'
LuaMidi.Track = require 'LuaMidi.Track'
LuaMidi.Util = require 'LuaMidi.Util'
LuaMidi.Writer = require 'LuaMidi.Writer'

function LuaMidi.get_MIDI_tracks(path)
   local MIDI = io.open(path, 'rb')
   if MIDI then
      local buffer = {}
      for line in MIDI:lines() do
         for i=1, #line do
            buffer[#buffer+1] = string.byte(line:sub(i,i))
         end
      end
      MIDI:close()
      local append = false
      local track_list = {}
      local track_number = 0
      for i=1, #buffer do
         if LuaMidi.Util.is_track_header({buffer[i], buffer[i+1], buffer[i+2], buffer[i+3]}) then
            append = true
            track_number = track_number + 1
            track_list[track_number] = {}
         end
         if buffer[i] == 0x00 and
            buffer[i+1] == 0xFF and
            buffer[i+2] == 0x2F and
            buffer[i+3] == 0x00 then
            append = false
         end
         if append then
            table.insert(track_list[track_number],buffer[i])
         end
      end
      for track_number, raw_track in ipairs(track_list) do
         local track = {
            type = {raw_track[1], raw_track[2], raw_track[3], raw_track[4]},
            events = {}
         }
         for i=1, 8 do table.remove(raw_track,1) end
         track.size = LuaMidi.Util.number_to_bytes(#raw_track, 4)
         track.data = raw_track
         track = setmetatable(track, { __index = LuaMidi.Track })
         track_list[track_number] = track
      end
      return track_list
   end
end

return LuaMidi
