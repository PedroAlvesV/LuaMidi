local Constants = require('LuaMidi.Constants')
local Util = require('LuaMidi.Util')
local NoteOnEvent = require('LuaMidi.NoteOnEvent')
local NoteOffEvent = require('LuaMidi.NoteOffEvent')

local NoteEvent = {}

function NoteEvent.new(fields)
   local self = {
      type = 'note',
      pitch = fields.pitch,
      wait = fields.wait or 0,
      duration = fields.duration,
      sequential = fields.sequential or false,
      velocity = fields.velocity or 50,
      channel = fields.channel or 1,
      repeatition = fields.repeat or 1,
   }
   function convert_velocity(velocity)
      -- must test
      if velocity > 100 then
         velocity = 100
      end
      return math.round(velocity / 100 * 127)
   end
   self.velocity = convert_velocity(self.velocity)
   self.get_tick_duration = function(duration, type)
      if tostring(duration):lower():sub(1,1) == 't' then
         return string.match(tostring(duration),"%d+")
      end
      local quarter_ticks = Util.number_from_bytes(Constants.HEADER_CHUNK_DIVISION)
      return math.round(quarter_ticks * self.get_duration_multiplier(duration, type))
   end
   self.build_data = function()
      self.data = {}
      local tick_duration = self.get_tick_duration(self.duration, 'note')
      local rest_duration = self.get_tick_duration(self.wait, 'rest')
      local note_on, note_off
      if type(self.pitch) == 'table' then
         if not self.sequential then
            for i=1, self.repetition do
               for i, p in ipairs(self.pitch) do
                  local fields = {}
                  if i == 1 then
                     local data = Util.num_to_var_length(rest_duration)
                     data[#data+1] = self.get_note_on_status()
                     data[#data+1] = Util.get_pitch(p)
                     data[#data+1] = self.velocity
                     fields.data = data
                  else
                     local data = {0, Util.get_pitch(p), self.velocity}
                     fields.data = data
                  end
                  note_on = NoteOnEvent.new(fields)
                  self.data = Util.table_concat(self.data, note_on.data)
               end
               for i, p in ipairs(self.pitch) do
                  local fields = {}
                  if i == 1 then
                     local data = Util.num_to_var_length(tick_duration)
                     data[#data+1] = self.get_note_off_status()
                     data[#data+1] = Util.get_pitch(p)
                     data[#data+1] = self.velocity
                     fields.data = data
                  else
                     local data = {0, Util.get_pitch(p), self.velocity}
                     fields.data = data
                  end
                  note_off = NoteOffEvent.new(fields)
                  self.data = Util.table_concat(self.data, note_off.data)
               end
            end
         else
            for i=1, self.repetition do
               -- TODO
            end
         end
      else
         print("Pitch must be an array.")
      end
   end
   self.build_data()
   return setmetatable(self, { __index = NoteEvent })
end

function NoteEvent:get_duration_multiplier(duration, type)
   if duration == '0' then
      return 0
   elseif duration == '1' then
      return 4
   elseif duration == '2' then
      return 2
   elseif duration == 'd2' then
      return 3
   elseif duration == '4' then
      return 1
   elseif duration == 'd4' then
      return 1.5
   elseif duration == '8' then
      return 0.5
   elseif duration == '8t' then
      return 0.33
   elseif duration == 'd8' then
      return 0.75
   elseif duration == '16' then
      return 0.25
   else
      if type == 'note' then
         return 1
      end
      return 0
   end
end

function NoteEvent:get_note_on_status()
   return 144 + self.channel - 1
end

function NoteEvent:get_note_off_status()
   return 128 + self.channel - 1
end

return NoteEvent