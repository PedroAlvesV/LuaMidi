-------------------------------------------------
-- Manage to join all tracks and features output
-- methods.
--
-- @classmod Writer
-- @author Pedro Alves
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
-- Creates a new Writer
--
-- @param tracks a track object or a table of tracks
--
-- @return 	new Writer object
--
-- @see Track
-------------------------------------------------
function Writer.new(tracks)
   local self = {
      data = {},
   }
   if #tracks == 0 and tracks.type then
      if Util.is_track_header(tracks.type) then
         tracks = {tracks}
      end
   end
   local track_type = Constants.HEADER_CHUNK_FORMAT0
   if #tracks > 1 then
      track_type = Constants.HEADER_CHUNK_FORMAT1
   end
   local chunk_data = Util.table_concat(track_type, Util.number_to_bytes(#tracks, 2))
   chunk_data = Util.table_concat(chunk_data, Constants.HEADER_CHUNK_DIVISION)
   self.data[1] = Chunk.new({
      type = Constants.HEADER_CHUNK_TYPE,
      data = chunk_data,
   })
   for i, track in ipairs(tracks) do
      track:add_event(MetaEvent.new({data = Constants.META_END_OF_TRACK_ID}))
      self.data[#self.data+1] = track
   end
   return setmetatable(self, { __index = Writer })
end

-------------------------------------------------
-- Concatenates everything to an array.
-- This array is must be unpacked and translated
-- to binary to produce a MIDI file.
-- <p>**Note:** This function should not be invoked
-- by the user. It's purpose is debugging LuaMidi.
--
-- @return 	builded array
--
-- @see save_MIDI
-------------------------------------------------
function Writer:build_file()
   local build = {}
   for _, elem in ipairs(self.data) do
      build = Util.table_concat(build, elem.type)
      build = Util.table_concat(build, elem.size)
      build = Util.table_concat(build, elem.data)
   end
   return build
end

-------------------------------------------------
-- Prints the array produced by `Writer:build_file()`.
-- <p>**Note:** The user doesn't need to invoke
-- this function. It's purpose is debugging LuaMidi.
--
-- @bool show_index if `true`, shows elements index
--
-- @see save_MIDI
-------------------------------------------------
function Writer:stdout(show_index)
   local buffer = self:build_file()
   print('{')
   for i, byte in ipairs(buffer) do
      io.write('  ')
      if show_index then io.write(i..' - ') end
      io.write(byte)
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
   local buffer = string.char(table.unpack(self:build_file()))
   file:write(buffer)
   file:close()
end

return Writer
