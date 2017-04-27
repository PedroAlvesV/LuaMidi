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
-- @return 	new Track object
-------------------------------------------------
function Track.new()
   local self = {
      type = Constants.TRACK_CHUNK_TYPE,
      data = {},
      size = {},
      events = {},
   }
   return setmetatable(self, { __index = Track })
end

-------------------------------------------------
-- Adds an event (or event-list) to the track. These events can be
-- `MetaEvents`, `NoteEvents` or `ProgramChangeEvents`. 
--
-- @param event a single event or event-list (array of events).
-- @param map_function function to be applied to `event` (being it an array or not).
--
-- @see MetaEvent
-- @see NoteEvent
-- @see ProgramChangeEvent
--
-- @return 	new Track object
-------------------------------------------------
function Track:add_event(event, map_function)
   if (type(event) == 'table') and (event[1] ~= nil) then -- roughly checking if it's an array
      for i, e in ipairs(event) do
         if (type(map_function) == 'function') and (e.type == 'note') then
            local properties = map_function(i, e)
            if type(properties) == 'table' then -- not accurate
               e.duration = properties.duration
               e.sequential = properties.sequential
               e.velocity = e.convert_velocity(properties.velocity)
               e.build_data()
            end
         end
         self.data = Util.table_concat(self.data, e.data)
         self.size = Util.number_to_bytes(#self.data, 4)
         self.events[#self.events+1] = e
      end
   else
      self.data = Util.table_concat(self.data, event.data)
      self.size = Util.number_to_bytes(#self.data, 4)
      self.events[#self.events+1] = event
   end
   return self
end

-------------------------------------------------
-- Sets Track's tempo
--
-- @number bpm the tempo in beats per minute.
--
-- @return 	Track with tempo
-------------------------------------------------
function Track:set_tempo(bpm)
   -- must test
   local event = MetaEvent.new({data = {Constants.META_TEMPO_ID}})
   event.data[#event.data+1] = 0x03
   local tempo = Util.round(60000000/bpm)
   event.data = Util.table_concat(event.data, Util.number_to_bytes(tempo, 3))
   return self:add_event(event)
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
   midi_clocks_per_tick = midi_clocks_per_tick or 24
   notes_per_midi_clock = notes_per_midi_clock or 8
   local event = MetaEvent.new({data = {Constants.META_TIME_SIGNATURE_ID}})
   event.data[#event.data+1] = 0x04
   event.data = Util.table_concat(Util.number_to_bytes(numerator, 1))
   denominator = math.log(denominator, 2)
   event.data = Util.table_concat(event.data, Util.number_to_bytes(denominator, 1))
   event.data = Util.table_concat(event.data, Util.number_to_bytes(midi_clocks_per_tick, 1))
   event.data = Util.table_concat(event.data, Util.number_to_bytes(notes_per_midi_clock, 1))
   return self:add_event(event)
end

-------------------------------------------------
-- Sets Track's key signature
--
-- @param sf signature's top number
-- @param mi signature's bottom number
--
-- @see MetaEvent
--
-- @return 	Track with key signature
-------------------------------------------------
function Track:set_key_signature(sf, mi)
   -- must test
   local event = MetaEvent.new({data = {Constants.META_KEY_SIGNATURE_ID}})
   event.data[#event.data+1] = 0x02
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
   return self:add_event(event)
end

local function default_add_text(self, text, constant)
   local event = MetaEvent.new({data = {constant}})
   local string_bytes = Util.string_to_bytes(text)
   event.data = Util.table_concat(event.data, Util.num_to_var_length(#string_bytes))
   event.data = Util.table_concat(event.data, string_bytes)
   return self:add_event(event)
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
   return default_add_text(self, text, Constants.META_COPYRIGHT_ID)
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
   return default_add_text(self, name, Constants.META_INSTRUMENT_NAME_ID)
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
   return default_add_text(self, text, Constants.META_CUE_POINT)
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
   return default_add_text(self, lyric, Constants.META_LYRIC_ID)
end

-------------------------------------------------
-- Activates poly mode
--
-- @return 	Track with poly mode activated
-------------------------------------------------
function Track:poly_mode_on()
   -- must test
   local event = NoteOnEvent.new({data = {0x00, 0xB0, 0x7E, 0x00}})
   return self:add_event(event)
end

return Track
