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
      repetition = fields.repetition or 1,
   }
   self.convert_velocity = function(velocity)
		velocity = velocity or 50
		if velocity > 100 then
         velocity = 100
      end
      return Util.round(velocity / 100 * 127)
   end
   self.velocity = self.convert_velocity(self.velocity)
   self.get_tick_duration = function(duration, type)
      if tostring(duration):lower():sub(1,1) == 't' then
         return string.match(tostring(duration),"%d+")
      end
      local quarter_ticks = Util.number_from_bytes(Constants.HEADER_CHUNK_DIVISION)
      return Util.round(quarter_ticks * self.get_duration_multiplier(duration, type))
   end
	self.get_duration_multiplier = function(duration, type)
	   duration = tostring(duration)
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
	self.get_note_on_status = function()
		return 144 + self.channel - 1
	end
	self.get_note_off_status = function()
		return 128 + self.channel - 1
	end
   self.build_data = function()
      self.data = {}
      local tick_duration = self.get_tick_duration(self.duration, 'note')
      local rest_duration = self.get_tick_duration(self.wait, 'rest')
      local note_on, note_off
      if type(self.pitch) == 'table' then
         if not self.sequential then
            for j=1, self.repetition do
               for i, p in ipairs(self.pitch) do
                  local fields = {}
                  local data
                  if i == 1 then
                     data = Util.num_to_var_length(rest_duration)
                     data[#data+1] = self.get_note_on_status()
                     data[#data+1] = Util.get_pitch(p)
                     data[#data+1] = self.velocity
                  else
                     data = {0, Util.get_pitch(p), self.velocity}
                  end
                  fields.data = data
                  note_on = NoteOnEvent.new(fields)
                  self.data = Util.table_concat(self.data, note_on.data)
               end
               for i, p in ipairs(self.pitch) do
                  local fields = {}
                  local data
                  if i == 1 then
                     data = Util.num_to_var_length(tick_duration)
                     data[#data+1] = self.get_note_off_status()
                     data[#data+1] = Util.get_pitch(p)
                     data[#data+1] = self.velocity
                  else
                     data = {0, Util.get_pitch(p), self.velocity}
                  end
                  fields.data = data
                  note_off = NoteOffEvent.new(fields)
                  self.data = Util.table_concat(self.data, note_off.data)
               end
            end
         else
            for j=1, self.repetition do
               for i, p in ipairs(self.pitch) do
                  local fields = {}
                  if i > 1 then
                     rest_duration = 0
                  end
                  if (self.duration == '8t') and i == #self.pitch then
                     local quarter_ticks = Util.number_from_bytes(Constants.HEADER_CHUNK_DIVISION)
                     tick_duration = quarter_ticks - (tick_duration * 2)
                  end
                  local fieldsOn, fieldsOff = {}, {}
                  
                  local dataOn = Util.num_to_var_length(rest_duration)
                  dataOn[#dataOn+1] = self.get_note_on_status()
                  dataOn[#dataOn+1] = Util.get_pitch(p)
                  dataOn[#dataOn+1] = self.velocity
                  fieldsOn.data = dataOn
                  note_on = NoteOnEvent.new(fieldsOn)
                  
                  local dataOff = Util.num_to_var_length(tick_duration)
                  dataOff[#dataOff+1] = self.get_note_off_status()
                  dataOff[#dataOff+1] = Util.get_pitch(p)
                  dataOff[#dataOff+1] = self.velocity
                  fieldsOff.data = dataOff
                  note_off = NoteOffEvent.new(fieldsOff)
                  
                  self.data = Util.table_concat(self.data, dataOn)
                  self.data = Util.table_concat(self.data, dataOff)
               end
            end
         end
      else
         print("Pitch must be an array.")
      end
   end
   self.build_data()
   return setmetatable(self, { __index = NoteEvent })
end

return NoteEvent
