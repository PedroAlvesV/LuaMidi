local LuaMidi = require ('LuaMidi')
local Track = LuaMidi.Track
local NoteEvent = LuaMidi.NoteEvent
local Writer = LuaMidi.Writer

local n = tonumber(arg[1])

if n == 1 then

   local track = Track.new()
   track:set_name("i-juca")
   track:add_events(NoteEvent.new({pitch = 'C4'}))

   local track2 = Track.new()
   track2:set_name("pirama")
   track2:add_events(NoteEvent.new({pitch = 'G4'}))

   require 'mm'(track)
   io.write('------------------------------------------\n')
   require 'mm'(track2)

   local writer = Writer.new({track, track2})
   writer:save_MIDI('test', 'midi files')

elseif n == 2 then
   
   local track = Track.new()
   track:set_name("i-juca")
   track:add_events(NoteEvent.new({pitch = 'C4'}))

   require 'mm'(track)

   local writer = Writer.new({track, track2})
   writer:save_MIDI('test', 'midi files')
   
else

   tracks = LuaMidi.get_MIDI_tracks('midi files/test.mid') 
   require 'mm'(tracks)

end
