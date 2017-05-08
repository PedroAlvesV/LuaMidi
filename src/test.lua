local LuaMidi = require ('LuaMidi')
local Track = LuaMidi.Track
local NoteEvent = LuaMidi.NoteEvent

local notes = {'G3', 'A3', 'B3', 'C4', 'D4', 'E4', 'F4', 'G4'}

local fifths = Track.new()
fifths:add_event(NoteEvent.new({pitch = notes, sequential = true}))

LuaMidi.add_tracks_to_MIDI('midi files/C Major Scale.mid', fifths, 'midi files/test.mid')
