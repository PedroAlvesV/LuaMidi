local LuaMidi = require ('LuaMidi')
local Track = LuaMidi.Track
local NoteEvent = LuaMidi.NoteEvent
local Writer = LuaMidi.Writer

local track = Track.new()

track:add_event(
   {
      NoteEvent.new({pitch = {'E4', 'D4'}, duration = '4'}),
      NoteEvent.new({pitch = {'C4'}, duration = '2'}),
      NoteEvent.new({pitch = {'E4', 'D4'}, duration = '4'}),
      NoteEvent.new({pitch = {'C4'}, duration = '2'}),
      NoteEvent.new({pitch = {'C4', 'C4', 'C4', 'C4', 'D4', 'D4', 'D4', 'D4'}, duration = '8'}),
      NoteEvent.new({pitch = {'E4', 'D4'}, duration = '4'}),
      NoteEvent.new({pitch = {'C4'}, duration = '2'}),
   },
   function(index, event)
      return {sequencial = true}
   end
)

local writer = Writer.new({track})
writer:save_MIDI('Hot Cross Buns', 'midi files')
