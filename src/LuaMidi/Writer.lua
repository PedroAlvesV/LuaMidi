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
   local num_tracks = Util.number_to_bytes(#tracks, 2)
   self.data = -- TODO
   tracks -- TODO
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