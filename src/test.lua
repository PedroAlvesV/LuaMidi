local LuaMidi = require ('LuaMidi')
local Track = LuaMidi.Track
local NoteEvent = LuaMidi.NoteEvent
local Writer = LuaMidi.Writer

local track = Track.new()

track:add_event({NoteEvent.new({pitch = {'C4'}, duration = '4'})})

local writer = Writer.new({track})
writer:stdout()
writer:save_MIDI('test', 'midi files')
