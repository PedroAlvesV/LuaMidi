-------------------------------------------------
-- Manages to join all tracks and features output
-- methods.
--
-- @classmod Writer
-- @author Pedro Alves Valentim
-- @license MIT
--
-- @see Track
-------------------------------------------------

local Util = require('LuaMidi.Util')
local Constants = require('LuaMidi.Constants')
local Chunk = require('LuaMidi.Chunk')
local MetaEvent = require('LuaMidi.MetaEvent')

local Writer = {}

-------------------------------------------------
--- Functions
-- @section functions
-------------------------------------------------

-------------------------------------------------
-- Creates a new Writer
--
-- @param tracks a track object or a table of tracks
--
-- @return 	new Writer object
--
-- @see Track
-------------------------------------------------
function Writer.new(tracks)
   assert(type(tracks) == 'table' and (tracks.type or tracks[1].type), "'tracks' must be a Track object or array of Track objects")
   if #tracks == 0 and tracks.type then
      if Util.is_track_header(tracks.type) then
         tracks = {tracks}
      end
   end
   local self = {
      data = {},
      tracks = tracks,
   }
   self.build_track = function(track)
      for i=1, #track.events do
         local event = track.events[i]
         if event.type == 'note' then
            event.build_data()
         end
         track.data = Util.table_concat(track.data, event.data)
         track.size = Util.number_to_bytes(#track.data, 4)
      end
      return track
   end
   self.build_writer = function(new_tracks, total_tracks)
      local track_type = Constants.HEADER_CHUNK_FORMAT0
      if total_tracks > 1 then
         track_type = Constants.HEADER_CHUNK_FORMAT1
      end
      local chunk_data = Util.table_concat(track_type, Util.number_to_bytes(total_tracks, 2))
      chunk_data = Util.table_concat(chunk_data, Constants.HEADER_CHUNK_DIVISION)
      self.data[1] = Chunk.new({
         type = Constants.HEADER_CHUNK_TYPE,
         data = chunk_data,
      })
      for i=1, #new_tracks do
         local track = new_tracks[i]
         track:add_events(MetaEvent.new({data = Constants.META_END_OF_TRACK_ID}))
         track = self.build_track(track)
         self.data[#self.data+1] = track
      end
   end
   self.build_writer(self.tracks, #self.tracks)
   return setmetatable(self, { __index = Writer })
end

-------------------------------------------------
--- Methods
-- @section methods
-------------------------------------------------

-------------------------------------------------
-- Adds one or more tracks to Writer
--
-- @param new_tracks a track object or a table of tracks
-- to be added
--
-- @see Track
-------------------------------------------------
function Writer:add_tracks(new_tracks)
   assert(type(new_tracks) == 'table' and (new_tracks.type or new_tracks[1].type), "'new_tracks' must be a Track object or array of Track objects")
   if #new_tracks == 0 and new_tracks.type then
      if Util.is_track_header(new_tracks.type) then
         new_tracks = {new_tracks}
      end
   end
   self.tracks = Util.table_concat(self.tracks, new_tracks)
   self.build_writer(new_tracks, #self.tracks)
end

-------------------------------------------------
-- Concatenates everything to an array.
-- This array is must be unpacked and translated
-- to binary to produce a MIDI file.
-- <p>**Note:** This method should not be called
-- by the user. It's accessible for debugging purposes.
--
-- @return 	builded array
--
-- @see save_MIDI
-------------------------------------------------
function Writer:build_file()
   local build = {}
   for i=1, #self.data do
      local elem = self.data[i]
      build = Util.table_concat(build, elem.type)
      build = Util.table_concat(build, elem.size)
      build = Util.table_concat(build, elem.data)
   end
   return build
end

-------------------------------------------------
-- Prints the array produced by `Writer:build_file()`.
-- <p>**Note:** The user doesn't need to call
-- this method. It's purpose is debugging LuaMidi.
--
-- @bool show_index if `true`, shows elements index
--
-- @see save_MIDI
-------------------------------------------------
function Writer:stdout(show_index)
   local buffer = self:build_file()
   print('{')
   for i=1, #buffer do
      local byte = buffer[i]
      io.write('  ')
      if show_index then io.write(i..' - ') end
      local byteStr = Util.convert_base(byte, 16)
      if #byteStr < 2 then
         byteStr = "0"..byteStr
      end
      io.write(byteStr)
      if i < #buffer then io.write(',') end
      io.write('\n')
   end
   print('}')
end

-------------------------------------------------
-- Writes MIDI file.
--
-- @string title file's title
-- @string[opt] directory a directory path to save the file
-------------------------------------------------
function Writer:save_MIDI(title, directory)
   if title:sub(#title-3) ~= ".mid" then title = title..".mid" end
   if type(directory) == 'string' and #directory ~= 0 then
      if not os.rename(directory, directory) then
         os.execute("mkdir ".."'"..directory.."'")
      end
      if directory:sub(-1) == '/' then
         title = directory..title
      else
         title = directory..'/'..title
      end
   end
   local file = io.open(title, 'wb')
   local bytes = self:build_file()
   local buffer = ""
   for i=1, #bytes do
      local byte = bytes[i]
      buffer = buffer..string.char(byte)
   end
   file:write(buffer)
   file:close()
end

return Writer
