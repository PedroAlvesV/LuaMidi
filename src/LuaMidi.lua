-------------------------------------------------
-- LuaMidi Library Class
-- <p>All modules are available through it.
-- It also presents useful functions to handle
-- MIDI files.
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

-------------------------------------------------
-- Functions
-- @section Functions
-------------------------------------------------

-------------------------------------------------
-- Reads all tracks from a MIDI file and convert
-- them to LuaMidi's Track objects.
--
-- @string path the MIDI file path
--
-- @return an array of the tracks
--
-- @see Track
-------------------------------------------------
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
            events = {},
            metadata = {},
            size = {},
         }
         for i=1, 8 do table.remove(raw_track,1) end
         local metadata_types = LuaMidi.Constants.METADATA_TYPES
         for i=1, #raw_track do
            if raw_track[i] == 0x00 and raw_track[i+1] == 0xFF then
               local raw_metadata = {}
               local k = i+3
               for j=i, k+raw_track[k] do
                  raw_metadata[#raw_metadata+1] = raw_track[j]
               end
               local converted_data
               if raw_track[i+2] < 0x08 then
                  converted_data = ""
                  for j=5, #raw_metadata do
                     converted_data = converted_data..string.char(raw_metadata[j])
                  end
               elseif raw_track[i+2] == LuaMidi.Constants.META_TEMPO_ID then
                  local data_bytes = {raw_track[i+4], raw_track[i+5], raw_track[i+6]}
                  local ms = LuaMidi.Util.number_from_bytes(data_bytes)
                  local bpm = LuaMidi.Util.round(60000000/ms)
                  converted_data = tostring(ms).." ms ("..bpm.."bpm)"
               elseif raw_track[i+2] == LuaMidi.Constants.META_TIME_SIGNATURE_ID then
                  converted_data = raw_track[i+4]
                  converted_data = converted_data.."/"..math.ceil(2^raw_track[i+5])
               elseif raw_track[i+2] == LuaMidi.Constants.META_KEY_SIGNATURE_ID then
                  local majmin = {'major', 'minor'}
                  local keys = {{'C','A'},{'G','E'},{'D','B'},{'A','F#'},
                     {'E','C#'},{'B','G#'},{'F#','D#'},{'C#','A#'}}
                  local sharps_num = tostring(raw_track[i+4])
                  converted_data = sharps_num.."#"
                  converted_data = converted_data.." ("..keys[sharps_num+1][raw_track[i+5]+1].." "..majmin[raw_track[i+5]+1]..")"
               end
               local subtype = metadata_types[raw_track[i+2]]
               track.metadata[subtype] = converted_data
               local event = {
                  type = 'meta',
                  subtype = subtype,
                  data = raw_metadata,
               }
               event = setmetatable(event, { __index = LuaMidi.MetaEvent })
               track.events[#track.events+1] = event
            elseif raw_track[i] == 0x00 and raw_track[i+1] == LuaMidi.Constants.PROGRAM_CHANGE_STATUS then
               local event = {
                  type = 'program-change',
                  data = { raw_track[i], raw_track[i+1], raw_track[i+2] }
               }
               event = setmetatable(event, { __index = LuaMidi.ProgramChangeEvent })
               track.events[#track.events+1] = event
            elseif raw_track[i] and raw_track[i+1] == 0x90 then
               local raw_note = {}
               do
                  local j=i
                  while raw_track[j] do
                     raw_note[#raw_note+1] = raw_track[j]
                     if raw_track[j+1] == 0x00 and raw_track[j+2] > 0x80 then
                        break
                     end
                     j=j+1
                  end
               end
               local channel = raw_note[2]-0x8F
               local velocity = raw_note[4]
               local pitch = {}
               do
                  local j=3
                  local kv_NOTES = LuaMidi.Util.table_invert(LuaMidi.Constants.NOTES)
                  while raw_note[j] and raw_note[j] < 0x81 do
                     if j%3 == 0 then
                        pitch[#pitch+1] = kv_NOTES[raw_note[j]]
                     end
                     j=j+1
                  end
               end
               local event = {
                  type = "note",
                  data = raw_note,
                  pitch = pitch,
                  velocity = velocity,
                  channel = channel,
                  sequential = false,
                  repetition = 1,
               }
               event = setmetatable(event, { __index = LuaMidi.NoteEvent })
               track.events[#track.events+1] = event
            end
         end
         track = setmetatable(track, { __index = LuaMidi.Track })
         track_list[track_number] = track
      end
      return track_list
   end 
   return false
end

-------------------------------------------------
-- Adds tracks to a MIDI file.
--
-- @string input the original MIDI file path
-- @param tracks a track object or a table of tracks
-- @string[opt=`input`] output altered MIDI file path
--
-- @return `true` if successful, `false` if not
--
-- @see Track
-------------------------------------------------
function LuaMidi.add_tracks_to_MIDI(input, tracks, output)
   if not output then output = input end
   if input:sub(#input-3) ~= ".mid" and input:sub(#input-4) ~= ".midi" then
      return false
   end
   local MIDI = io.open(input, 'rb')
   if MIDI then
      local buffer = {}
      for line in MIDI:lines() do
         for i=1, #line do
            buffer[#buffer+1] = string.byte(line:sub(i,i))
         end
      end
      MIDI:close()
      if not (buffer[1] == 0x4D and
         buffer[2] == 0x54 and
         buffer[3] == 0x68 and
         buffer[4] == 0x64) then
         return false
      end
      if #tracks == 0 and tracks.type then
         if LuaMidi.Util.is_track_header(tracks.type) then
            tracks = {tracks}
         end
      end
      buffer[10] = 0x01
      local original_n_tracks = 0
      for i=1, #buffer do
         if LuaMidi.Util.is_track_header({buffer[i], buffer[i+1], buffer[i+2], buffer[i+3]}) then
            original_n_tracks = original_n_tracks + 1
         end
      end
      local bytes_n_tracks = LuaMidi.Util.number_to_bytes(original_n_tracks + #tracks, 2)
      buffer[11] = bytes_n_tracks[1]
      buffer[12] = bytes_n_tracks[2]
      local tracks_bytes = {}
      for _, track in ipairs(tracks) do
         track:add_events(LuaMidi.MetaEvent.new({data = LuaMidi.Constants.META_END_OF_TRACK_ID}))
         local raw_track = LuaMidi.Util.table_concat(track.type, track.size)
         raw_track = LuaMidi.Util.table_concat(raw_track, track.data)
         tracks_bytes[#tracks_bytes+1] = raw_track
      end
      for _, track in ipairs(tracks_bytes) do
         buffer = LuaMidi.Util.table_concat(buffer, track)
      end
      MIDI = io.open(output, 'wb')
      local unpack = unpack or table.unpack
      buffer = string.char(unpack(buffer))
      MIDI:write(buffer)
      MIDI:close()
      return true
   end
   return false
end

return LuaMidi
