local LuaMidi = require ('LuaMidi')
local Track = LuaMidi.Track
local NoteEvent = LuaMidi.NoteEvent
local Writer = LuaMidi.Writer

local track = LuaMidi.get_MIDI_tracks('test.mid')
track = track[1]

print(track:get_text())
print(track:get_copyright())
print(track:get_name())
print(track:get_instrument_name())
print(track:get_lyric())
print(track:get_marker())
print(track:get_cue_point())
