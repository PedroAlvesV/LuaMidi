local Util = require('LuaMidi.Util')
local Constants = require('LuaMidi.Constants')

local Writer = {}

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
   self.data[#self.data+1] = Chunk.new({
      type = Constants.HEADER_CHUNK_TYPE,
      data = chunk_data,
   })
   for i, track in ipairs(tracks) do
      track:add_event(MetaEvent.new({data = Constants.META_END_OF_TRACK_ID}))
      self.data[#self.data+1] = track
   end
   return setmetatable(self, { __index = Writer })
end

function Writer:build_file()
   local build {}
   self.data = -- TODO
   return -- TODO
end

function Writer:dataURI()
   -- TODO
end

function Writer:stdout()
   -- TODO
end

function Writer:save_MIDI()
   local buffer = -- TODO
   -- TODO
end

return Writer
