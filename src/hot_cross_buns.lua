local LuaMidi = require ('LuaMidi')
local Track = LuaMidi.Track
local NoteEvent = LuaMidi.NoteEvent
local Writer = LuaMidi.Writer

local track = Track.new("Hot Cross Buns")
track:add_text("Popular nursery rhyme theme")
track:add_copyright("Public domain")
track:add_instrument_name("Default")
track:add_lyric("'Hot Cross Buns!(2x)/One a penny, Two a penny/Hot Cross Buns!'")

track:add_events(
   {
      NoteEvent.new({pitch = {'E4', 'D4'}, duration = '4'}),
      NoteEvent.new({pitch = 'C4', duration = '2'}),
      NoteEvent.new({pitch = {'E4', 'D4'}, duration = '4'}),
      NoteEvent.new({pitch = 'C4', duration = '2'}),
      NoteEvent.new({pitch = {'C4', 'C4', 'C4', 'C4', 'D4', 'D4', 'D4', 'D4'}, duration = '8'}),
      NoteEvent.new({pitch = {'E4', 'D4'}, duration = '4'}),
      NoteEvent.new({pitch = 'C4', duration = '2'}),
   },
   function(index, event)
      return {sequential = true}
   end
)

local writer = Writer.new(track)
writer:save_MIDI('hot_cross_buns', 'midi files')
