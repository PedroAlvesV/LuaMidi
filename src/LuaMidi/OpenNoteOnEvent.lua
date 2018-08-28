local Constants = require('LuaMidi.Constants')
local Util = require('LuaMidi.Util')
local NoteOnEvent = require('LuaMidi.NoteOnEvent')

local OpenNoteOnEvent = {}

function OpenNoteOnEvent.new(fields)
   assert(type(fields.pitch) == 'string' or type(fields.pitch) == 'number', "'pitch' must be a string or a number")
   local self = {
      type = 'open_note_on',
      pitch = fields.pitch,
      velocity = fields.velocity,
      delta = fields.delta_time,
      channel = fields.channel,
   }
   if self.delta ~= nil then
      assert( (type(self.delta) == 'string' and self.delta:sub(1,1):lower() == "t") or type(self.delta) == 'number' and self.delta >= 0, "'delta_time' must be an positive integer or a string representing the explicit number of ticks")
   else
      self.delta = 0
   end
   if self.velocity ~= nil then
      assert(type(self.velocity) == 'number' and self.velocity >= 1 and self.velocity <= 100, "'velocity' must be an integer from 1 to 100")
   else
      self.velocity = 50
   end
   if self.channel ~= nil then
      assert(type(self.channel) == 'number' and self.channel >= 1 and self.channel <= 16, "'channel' must be an integer from 1 to 16")
   else
      self.channel = 1
   end
   self.convert_velocity = function(velocity)
      return Util.round(velocity / 100 * 127)
   end
   self.velocity = self.convert_velocity(self.velocity)
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
	self.get_tick_duration = function(duration, type)
      if tostring(duration):sub(1,1):lower() == 't' then
         return string.match(tostring(duration),"%d+")
      end
      local quarter_ticks = Util.number_from_bytes(Constants.HEADER_CHUNK_DIVISION)
      return Util.round(quarter_ticks * self.get_duration_multiplier(duration, type))
   end
   self.build_data = function()
      
      self.data = {}
      
      local data = Util.num_to_var_length(self.get_tick_duration(self.delta, 'rest'))
      data[#data+1] = self.get_note_on_status()
      data[#data+1] = Util.get_pitch(self.pitch)
      data[#data+1] = self.velocity
      
      local note_on = NoteOnEvent.new({data = data})
      self.data = Util.table_concat(self.data, note_on.data)
      
   end
   self.build_data()
   return setmetatable(self, { __index = OpenNoteOnEvent })
end

-------------------------------------------------
-- Prints event's data in a human-friendly style
-------------------------------------------------
function OpenNoteOnEvent:print()
   local str = string.format("Pitch:\t\t%s\n", tostring(self.pitch))
   str = str..string.format("Velocity:\t%d\n", tostring(self.velocity))
   str = str..string.format("Channel:\t%d", tostring(self.channel))
   print("\nClass / Type:\tOpenNoteOnEvent / '"..self.type.."'")
   print(str)
end

function OpenNoteOnEvent:set_pitch(pitch)
   assert(type(pitch) == 'string' or type(pitch) == 'number', "'pitch' must be a string or a number")
   self.pitch = pitch
   self.build_data()
   return self
end

function OpenNoteOnEvent:set_velocity(velocity)
   assert(type(velocity) == 'number' and velocity >= 1 and velocity <= 100, "'velocity' must be an integer from 1 to 100")
   self.velocity = self.convert_velocity(velocity)
   self.build_data()
   return self
end

function OpenNoteOnEvent:set_channel(channel)
   assert(type(channel) == 'number' and channel >= 1 and channel <= 16, "'channel' must be an integer from 1 to 16")
   self.channel = channel
   self.build_data()
   return self
end

function OpenNoteOnEvent:get_pitch()
   return self.pitch
end

function OpenNoteOnEvent:get_velocity()
   return self.velocity
end

function OpenNoteOnEvent:get_channel()
   return self.channel
end

return OpenNoteOnEvent
