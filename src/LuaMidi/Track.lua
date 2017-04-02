local Util = require('LuaMidi.Util')
local Constants = require('LuaMidi.Constants')

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
   -- TODO
end

function Track:set_tempo(bpm)
   -- TODO
end

function Track:set_time_signature(numerator, denominator, midi_clocks_per_tick, notes_per_midi_clock)
   -- TODO
end

function Track:set_key_signature(sf, mi)
   -- TODO
end

local function default_add_text(text, constant)
   -- TODO
--   local event = MetaEvent({data: [constant]})
--	 var stringBytes = Utils.stringToBytes(text);
--	 event.data = event.data.concat(Utils.numberToVariableLength(stringBytes.length)); // Size
--	 event.data = event.data.concat(stringBytes); // Text
--	 return this.addEvent(event);
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
   -- TODO
--	var event = new NoteOnEvent({data: [0x00, 0xB0, 0x7E, 0x00]});
--	this.addEvent(event);
--	console.log(event);
end

return Track