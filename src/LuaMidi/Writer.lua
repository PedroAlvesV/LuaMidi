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
-- @param tracks a table containing tracks
--
-- @return 	new Writer object
--
-- @see Track
-------------------------------------------------
function Writer.new(tracks)
   local self = {
      data = {},
   }
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

function Writer:base64()
   -- TODO
end

function Writer:data_URI()
   -- TODO
end

function Writer:stdout()
   local mm = require 'mm'
   mm(self:build_file())
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
      title = directory..'/'..title
   end
   local file = io.open(title, 'wb')
   local buffer = string.char(table.unpack(self:build_file()))
   file:write(buffer)
   file:close()
end

return Writer
