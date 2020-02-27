local Constants = require('LuaMidi.Constants')
local Util = require('LuaMidi.Util')
local ArbitraryEvent = require('LuaMidi.ArbitraryEvent')

local NoteOffEvent = {}

function NoteOffEvent.new(fields)
   assert(type(fields.pitch) == 'string' or type(fields.pitch) == 'number', "'pitch' must be a string or a number")
   local self = {
      type = 'note_off',
      pitch = fields.pitch,
      velocity = fields.velocity,
      timestamp = fields.timestamp,
      channel = fields.channel,
   }
   if self.timestamp ~= nil then
      assert(type(self.timestamp) == 'number' and self.timestamp >= 0, "'timestamp' must be an positive integer representing the explicit number of ticks")
   else
      self.timestamp = 0
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
   self.get_note_off_status = function()
      return 128 + self.channel - 1
   end
   
   self.build_data = function()
      
      self.data = {}
      
      local data = Util.num_to_var_length(self.timestamp)
      data[#data+1] = self.get_note_off_status()
      data[#data+1] = Util.get_pitch(self.pitch)
      data[#data+1] = self.velocity
      
      local note_off = ArbitraryEvent.new({data = data})
      self.data = Util.table_concat(self.data, note_off.data)
      
   end
   self.build_data()
   return setmetatable(self, { __index = NoteOffEvent })
end

-------------------------------------------------
-- Prints event's data in a human-friendly style
-------------------------------------------------
function NoteOffEvent:print()
   local str = string.format("Pitch:\t\t%s\n", tostring(self.pitch))
   str = str..string.format("Velocity:\t%d\n", tostring(self.velocity))
   str = str..string.format("Channel:\t%d", tostring(self.channel))
   print("\nClass / Type:\tNoteOffEvent / '"..self.type.."'")
   print(str)
end

function NoteOffEvent:set_pitch(pitch)
   assert(type(pitch) == 'string' or type(pitch) == 'number', "'pitch' must be a string or a number")
   self.pitch = pitch
   self.build_data()
   return self
end

function NoteOffEvent:set_velocity(velocity)
   assert(type(velocity) == 'number' and velocity >= 1 and velocity <= 100, "'velocity' must be an integer from 1 to 100")
   self.velocity = self.convert_velocity(velocity)
   self.build_data()
   return self
end

function NoteOffEvent:set_channel(channel)
   assert(type(channel) == 'number' and channel >= 1 and channel <= 16, "'channel' must be an integer from 1 to 16")
   self.channel = channel
   self.build_data()
   return self
end

function NoteOffEvent:set_timestamp(timestamp)
   assert(type(self.timestamp) == 'number' and self.timestamp >= 0, "'timestamp' must be an positive integer representing the explicit number of ticks")
   self.timestamp = timestamp
   self.build_data()
   return self
end

function NoteOffEvent:get_pitch()
   return self.pitch
end

function NoteOffEvent:get_velocity()
   return self.velocity
end

function NoteOffEvent:get_channel()
   return self.channel
end

function NoteOffEvent:get_timestamp()
   return self.timestamp
end

return NoteOffEvent
