local LuaMidi = require ('LuaMidi')
local Track = LuaMidi.Track
local NoteEvent = LuaMidi.NoteEvent
local Writer = LuaMidi.Writer

local track = Track.new()

track:add_text('text')
track:add_copyright('copyright')
track:add_name('name')
track:add_instrument_name('instrument name')
track:add_lyric('lyric')
track:add_marker('marker')
track:add_cue_point('cue point')

print(track:get_text())
print(track:get_copyright())
print(track:get_name())
print(track:get_instrument_name())
print(track:get_lyric())
print(track:get_marker())
print(track:get_cue_point())

track:add_event(NoteEvent.new({pitch = {'C4', 'F4'}, duration = '2'}))

local writer = Writer.new(track)
writer:save_MIDI('test')

