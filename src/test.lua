local LuaMidi = require ('LuaMidi')
local Track = LuaMidi.Track
local NoteEvent = LuaMidi.NoteEvent
local Writer = LuaMidi.Writer

local track1 = Track.new()
track1:add_event({NoteEvent.new({pitch = {'A1'}})})

local track2 = Track.new()
track2:add_event({NoteEvent.new({pitch = {'A7'}})})

local writer = Writer.new({track1, track2})
--writer:add_tracks(track2)
writer:stdout()
writer:save_MIDI('test', 'midi files')
