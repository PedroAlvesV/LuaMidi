-------------------------------------------------
-- Contains all Track's data
--
-- @classmod Track
-- @author Pedro Alves
-- @license MIT
-------------------------------------------------

local Constants = require('LuaMidi.Constants')
local Util = require('LuaMidi.Util')
local MetaEvent = require('LuaMidi.MetaEvent')
local NoteOnEvent = require('LuaMidi.NoteOnEvent')

local Track = {}

-------------------------------------------------
-- Creates a new Track
--
-- @string[opt] name a name metadata to the Track
--
-- @return 	new Track object
-------------------------------------------------
function Track.new(name)
   local self = {
      type = Constants.TRACK_CHUNK_TYPE,
      data = {},
      size = {},
      events = {},
      metadata = {},
   }
   local obj = setmetatable(self, { __index = Track })
   if name then obj:add_name(name) end
   return obj
end

-------------------------------------------------
-- Adds an event-list (or single event) to the track. These events can be
-- `MetaEvents`, `NoteEvents` or `ProgramChangeEvents`. 
--
-- @param events a single event or event-list (array of events).
-- @param map_function function to be applied to `events` (being it an array or not).
--
-- @see MetaEvent
-- @see NoteEvent
-- @see ProgramChangeEvent
--
-- @return 	new Track object
-------------------------------------------------
function Track:add_events(events, map_function)
   if events.type then events = {events} end
   for i, event in ipairs(events) do
      if (type(map_function) == 'function') and (event.type == 'note') then
         local properties = map_function(i, event)
         if type(properties) == 'table' then
            event.duration = properties.duration or event.duration
            event.sequential = properties.sequential or event.sequential
            event.velocity = event.convert_velocity(properties.velocity or event.velocity)
         end
      end
      self.events[#self.events+1] = event
   end
   return self
end

-------------------------------------------------
-- Gets events from Track
--
-- @string filter a string to filter events by type. The valid values are `meta`, `note` and `program-change`.
--
-- @see MetaEvent
-- @see NoteEvent
-- @see ProgramChangeEvent
--
-- @return 	events table
-------------------------------------------------
function Track:get_events(filter)
   if filter then
      local events = {}
      for _, event in ipairs(self.events) do
         if event.type == filter then
            events[#events+1] = event
         end
      end
      return events
   end
   return self.events
end

-------------------------------------------------
-- Sets Track's tempo
--
-- @number bpm the tempo in beats per minute.
--
-- @return 	Track with tempo
-------------------------------------------------
function Track:set_tempo(bpm)
   local constant = Constants.META_TEMPO_ID
   local event = MetaEvent.new({data = {constant}})
   event.data[#event.data+1] = 0x03
   local tempo = Util.round(60000000/bpm)
   event.data = Util.table_concat(event.data, Util.number_to_bytes(tempo, 3))
   event.subtype = Constants.METADATA_TYPES[constant]
   return self:add_events(event)
end

-------------------------------------------------
-- Sets Track's time signature
--
-- @int num signature's numerator (top number)
-- @int den signature's denominator (bottom number)
-- @param[opt=<code>24</code>] midi_clocks_tick number of MIDI clocks per ticks
-- @param[opt=<code>8</code>] notes_midi_clock number of notes per MIDI clock
--
-- @see MetaEvent
--
-- @return 	Track with time signature
-------------------------------------------------
function Track:set_time_signature(num, den, midi_clocks_tick, notes_midi_clock)
   midi_clocks_tick = midi_clocks_tick or 24
   notes_midi_clock = notes_midi_clock or 8
   den = math.log(den, 2)
   local constant = Constants.META_TIME_SIGNATURE_ID
   local event = MetaEvent.new({data = {constant}})
   event.data[#event.data+1] = 0x04
   event.data = Util.table_concat(event.data, Util.number_to_bytes(num, 1))
   event.data = Util.table_concat(event.data, Util.number_to_bytes(den, 1))
   event.data = Util.table_concat(event.data, Util.number_to_bytes(midi_clocks_tick, 1))
   event.data = Util.table_concat(event.data, Util.number_to_bytes(notes_midi_clock, 1))
   event.subtype = Constants.METADATA_TYPES[constant]
   return self:add_events(event)
end

-------------------------------------------------
-- Sets Track's key signature
--
-- @param sf number of sharps or flats
-- @param mi[opt=0] major or minor (0 or 1)
--
-- @see MetaEvent
--
-- @return 	Track with key signature
-------------------------------------------------
function Track:set_key_signature(sf, mi)
   local constant = Constants.META_KEY_SIGNATURE_ID
   local event = MetaEvent.new({data = {constant}})
   event.data[#event.data+1] = 0x02
   sf = sf%8
   mi = mi%2
   local mode = mi or 0
   sf = sf or 0
   if not mi then
      local fifths = {
         {'Cb', 'Gb', 'Db', 'Ab', 'Eb', 'Bb', 'F', 'C', 'G', 'D', 'A', 'E', 'B', 'F#', 'C#'},
         {'ab', 'eb', 'bb', 'f', 'c', 'g', 'd', 'a', 'e', 'b', 'f#', 'c#', 'g#', 'd#', 'a#'}
      }
      local note = sf or 'C'
      if sf:sub(1,1) == string.lower(sf:sub(1,1)) then
         mode = 1
      end
      if #sf > 1 then
         local starts_with = sf:sub(#sf,#sf)
         if starts_with == 'm' or starts_with == '-' then
            mode = 1
            note = string.lower(sf:sub(1,1))
         elseif starts_with == 'M' or start_with == '+' then
            mode = 0
            note = string.upper(sf:sub(1,1))
         end
         note = note .. sf:sub(2, #sf)
      end
      local fifth_index = Util.table_index_of(fifths[mode], note)
      if not fifth_index then
         sf = 0
      else
         sf = fifth_index - 7
      end
   end
   event.data = Util.table_concat(event.data, Util.number_to_bytes(sf,1))
   event.data = Util.table_concat(event.data, Util.number_to_bytes(mode,1))
   event.subtype = Constants.METADATA_TYPES[constant]
   return self:add_events(event)
end

local function default_add_text(self, text, constant)
   local event = MetaEvent.new({data = {constant}})
   local string_bytes = Util.string_to_bytes(text)
   event.data = Util.table_concat(event.data, Util.num_to_var_length(#string_bytes))
   event.data = Util.table_concat(event.data, string_bytes)
   event.subtype = Constants.METADATA_TYPES[constant]
   return self:add_events(event)
end

-------------------------------------------------
-- Adds text to Track
--
-- @string text the text to be added
--
-- @see MetaEvent
--
-- @return 	Track with text
-------------------------------------------------
function Track:add_text(text)
   self.metadata.Text = text
   return default_add_text(self, text, Constants.META_TEXT_ID)
end

-------------------------------------------------
-- Adds copyright to Track
--
-- @string text the copyright to be added
--
-- @see MetaEvent
--
-- @return 	Track with copyright
-------------------------------------------------
function Track:add_copyright(text)
   self.metadata.Copyright = text
   return default_add_text(self, text, Constants.META_COPYRIGHT_ID)
end

-------------------------------------------------
-- Adds a name to Track
--
-- @string name the name to be added
--
-- @see MetaEvent
--
-- @return 	Track with a name
-------------------------------------------------
function Track:add_name(name)
   self.metadata.Name = name
   return default_add_text(self, name, Constants.META_TRACK_NAME_ID)
end

-------------------------------------------------
-- Adds instrument name to Track
--
-- @string name the instrument name to be added
--
-- @see MetaEvent
--
-- @return 	Track with instrument name
-------------------------------------------------
function Track:add_instrument_name(name)
   self.metadata.Instrument = name
   return default_add_text(self, name, Constants.META_INSTRUMENT_NAME_ID)
end

-------------------------------------------------
-- Adds lyric to Track
--
-- @string lyric the lyric text to be added
--
-- @see MetaEvent
--
-- @return 	Track with the lyric
-------------------------------------------------
function Track:add_lyric(lyric)
   self.metadata.Lyric = lyric
   return default_add_text(self, lyric, Constants.META_LYRIC_ID)
end

-------------------------------------------------
-- Adds marker text to Track
--
-- @string text the marker text to be added
--
-- @see MetaEvent
--
-- @return 	Track with the marker text
-------------------------------------------------
function Track:add_marker(text)
   self.metadata.Marker = text
   return default_add_text(self, text, Constants.META_MARKER_ID)
end

-------------------------------------------------
-- Adds cue point to Track
--
-- @string text the cue point text to be added
--
-- @see MetaEvent
--
-- @return 	Track with the cue point
-------------------------------------------------
function Track:add_cue_point(text)
   self.metadata["Cue Point"] = text
   return default_add_text(self, text, Constants.META_CUE_POINT)
end

-------------------------------------------------
-- Activates poly mode
--
-- @return 	Track with poly mode activated
-------------------------------------------------
function Track:poly_mode_on()
   -- must test
   local event = NoteOnEvent.new({data = {0x00, 0xB0, 0x7E, 0x00}})
   return self:add_events(event)
end

-------------------------------------------------
-- Gets text from Track
--
-- @see MetaEvent
--
-- @return 	Track's text
-------------------------------------------------
function Track:get_text()
   return self.metadata.Text
end

-------------------------------------------------
-- Gets copyright from Track
--
-- @see MetaEvent
--
-- @return 	Track's copyright
-------------------------------------------------
function Track:get_copyright()
   return self.metadata.Copyright
end

-------------------------------------------------
-- Gets name from Track
--
-- @see MetaEvent
--
-- @return 	Track's name
-------------------------------------------------
function Track:get_name()
   return self.metadata.Name
end

-------------------------------------------------
-- Gets instrument name from Track
--
-- @see MetaEvent
--
-- @return 	Track's instrument name
-------------------------------------------------
function Track:get_instrument_name()
   return self.metadata.Instrument
end

-------------------------------------------------
-- Gets lyric from Track
--
-- @see MetaEvent
--
-- @return 	Track's lyric
-------------------------------------------------
function Track:get_lyric()
   return self.metadata.Lyric
end

-------------------------------------------------
-- Gets marker from Track
--
-- @see MetaEvent
--
-- @return 	Track's marker
-------------------------------------------------
function Track:get_marker()
   return self.metadata.Marker
end

-------------------------------------------------
-- Gets cue point from Track
--
-- @see MetaEvent
--
-- @return 	Track's cue point
-------------------------------------------------
function Track:get_cue_point()
   return self.metadata["Cue Point"]
end

return Track
