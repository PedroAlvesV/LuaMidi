local LuaMidi = require ('LuaMidi')
local Track = LuaMidi.Track
local NoteEvent = LuaMidi.NoteEvent
local Writer = LuaMidi.Writer

local track = Track.new()

local notes = {'C3', 'D3', 'E3', 'F3', 'G3', 'A3', 'B3', 'C4'}

local scale = {}

for i, note in ipairs(notes) do
   scale[i] = NoteEvent.new({pitch = {note}})
end

track:add_event(scale)

local writer = Writer.new({track})
--writer:stdout()
writer:save_MIDI('C Major Scale', 'midi files')
