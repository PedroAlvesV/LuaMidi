local Constants = require('LuaMidi.Constants')
local Util = require('LuaMidi.Util')
local MetaEvent = require('LuaMidi.MetaEvent')
local NoteOnEvent = require('LuaMidi.NoteOnEvent')

local Track = {}

function Track.new()
   local self = {
      type = Constants.TRACK_CHUNK_TYPE,
      data = {},
      size = {},
      events = {},
   }
   return setmetatable(self, { __index = Track })
end

function Track:add_event(event, map_function)
   -- must test
   if type(event) == 'table' then
      for i, e in ipairs(self.event) do
         if (type(map_function) == 'function') && (e.type == 'note') then
            local properties = map_function(i, e)
            if type(properties) == 'table' then -- i think (?)
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

function Track:set_tempo(bpm)
   -- must test
   local fields = {data = {Constants.META_TEMPO_ID}}
   local event = MetaEvent.new(fields)
   event.data[#event.data+1] = 0x03
   local tempo = Util.round(60000000/bpm)
   event.data = Util.table_concat(event.data, Util.number_to_bytes(tempo, 3))
   return self:add_event(event)
end

function Track:set_time_signature(numerator, denominator, midi_clocks_per_tick, notes_per_midi_clock)
   -- TODO
end

function Track:set_key_signature(sf, mi)
   -- TODO
end

local function default_add_text(text, constant)
   -- must test
   local event = MetaEvent.new({data = {constant}})
   local string_bytes = Util.string_to_bytes(text)
   event.data = Util.table_concat(event.data, Util.num_to_var_length(#string_bytes))
   event.data = Util.table_concat(event.data, string_bytes)
   return self:add_event(event)
end

function Track:add_text(text)
   return default_add_text(text, Constants.META_TEXT_ID)
end

function Track:add_copyright(text)
   return default_add_text(text, Constants.META_COPYRIGHT_ID)
end

function Track:add_instrument_name(name)
   return default_add_text(name, Constants.META_INSTRUMENT_NAME_ID)
end

function Track:add_marker(text)
   return default_add_text(text, Constants.META_MARKER_ID)
end

function Track:add_cue_point(text)
   return default_add_text(text, Constants.META_CUE_POINT)
end

function Track:add_lyric(lyric)
   return default_add_text(lyric, Constants.META_LYRIC_ID)
end

function Track:poly_mode_on()
   -- must test
   local event = NoteOnEvent({data = {0x00, 0xB0, 0x7E, 0x00}})
   self:add_event(event)
   print(event)
end

return Track