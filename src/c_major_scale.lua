local LuaMidi = require ('LuaMidi')
local Track = LuaMidi.Track
local NoteEvent = LuaMidi.NoteEvent
local Writer = LuaMidi.Writer

local track = Track.new("C Major Scale")
track:add_text("Major scale from C3 to C4.")
track:add_instrument_name("Default")

local notes = {'C3', 'D3', 'E3', 'F3', 'G3', 'A3', 'B3', 'C4'}

track:add_events(NoteEvent.new({pitch = notes, sequential = true}))

local writer = Writer.new(track)
writer:save_MIDI('c_major_scale', 'midi files')
