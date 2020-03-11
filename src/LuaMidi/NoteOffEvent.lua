-------------------------------------------------
-- Abstraction of MIDI Note Off event.
-- <p> Useful for arrangements `NoteEvent` can't
-- be produce.
--
-- @classmod NoteOffEvent
-- @author Pedro Alves Valentim
-- @license MIT
-- @see Limitations_of_NoteEvent.md
-------------------------------------------------

local Constants = require('LuaMidi.Constants')
local Util = require('LuaMidi.Util')
local ArbitraryEvent = require('LuaMidi.ArbitraryEvent')

local NoteOffEvent = {}

-------------------------------------------------
--- Functions
-- @section functions
-------------------------------------------------

-------------------------------------------------
-- Creates a new NoteOffEvent. Receives a `fields` table as
-- parameter. This table is expected to have some (or
-- all) of these fields:
-- <p>
--<table border="1">
--	<thead>
--		<tr align="center">
--			<th>Name</th>
--			<th>Type</th>
--			<th>Description</th>
--		</tr>
--	</thead>
--	<tbody>
--		<tr>
--			<td><b>pitch</b></td>
--			<td>string or number</td>
--			<td>Note to be set off. Can be a string or valid MIDI note code.  Format for string is <code>C#4</code>.</td>
--		</tr>
--		<tr bgcolor="#dddddd">
--			<td><b>timestamp</b></td>
--			<td>number</td>
--			<td>
--				Number of ticks between previous event and the execution of this event.  Default: <code>0</code>
--			</td>
--		</tr>
--		<tr>
--       <td><b>velocity</b></td>
--			<td>number</td>
--			<td>How quickly the note should stop, values 0-100.  Default: <code>50</code></td>
--		</tr>
--		<tr bgcolor="#dddddd">
--			<td><b>channel</b></td>
--			<td>number</td>
--			<td>MIDI channel to use.  Default: <code>1</code></td>
--		</tr>
--	</tbody>
--</table>
--
-- **Note:** `pitch` is the only required field
--
-- @param fields a table containing NoteOffEvent's properties
--
-- @return 	new NoteOffEvent object
-------------------------------------------------
function NoteOffEvent.new(fields)
   assert(type(fields.pitch) == 'string' or type(fields.pitch) == 'number', "'pitch' must be a string or a number")
   assert(Util.get_pitch(fields.pitch), "Invalid 'pitch' value: "..fields.pitch)
   local self = {
      type = 'note_off',
      pitch = fields.pitch,
      velocity = fields.velocity,
      timestamp = fields.timestamp,
      channel = fields.channel,
   }
   if self.timestamp ~= nil then
      assert(type(self.timestamp) == 'number' and self.timestamp >= 0, "'timestamp' must be a positive integer representing the explicit number of ticks")
   else
      self.timestamp = 0
   end
   if self.velocity ~= nil then
      assert(type(self.velocity) == 'number' and self.velocity >= 0 and self.velocity <= 100, "'velocity' must be an integer from 0 to 100")
   else
      self.velocity = 50
   end
   if self.channel ~= nil then
      assert(type(self.channel) == 'number' and self.channel >= 1 and self.channel <= 16, "'channel' must be an integer from 1 to 16")
   else
      self.channel = 1
   end
   self.velocity = Util.convert_velocity(self.velocity)
   
   self.build_data = function()
      
      self.data = {}
      
      local data = Util.num_to_var_length(self.timestamp)
      data[#data+1] = Util.get_note_off_status(self.channel)
      data[#data+1] = Util.get_pitch(self.pitch)
      data[#data+1] = self.velocity
      
      local note_off = ArbitraryEvent.new({data = data})
      self.data = Util.table_concat(self.data, note_off.data)
      
   end
   
   self.build_data()
   return setmetatable(self, { __index = NoteOffEvent })
end

-------------------------------------------------
--- Methods
-- @section methods
-------------------------------------------------

-------------------------------------------------
-- Prints event's data in a human-friendly style
-------------------------------------------------
function NoteOffEvent:print()
   local str = string.format("Pitch:\t\t%s\n", tostring(self.pitch))
   str = str..string.format("Velocity:\t%d\n", tostring(self.velocity))
   str = str..string.format("Channel:\t%d\n", tostring(self.channel))
   str = str..string.format("Timestamp:\t%d", tostring(self.timestamp))
   print("\nClass / Type:\tNoteOffEvent / '"..self.type.."'")
   print(str)
end

-------------------------------------------------
-- Sets NoteOffEvent's pitch
--
-- @param pitch takes the same values as the pitch
-- field passed to the constructor.
--
-- @return 	NoteOffEvent with new pitch
-------------------------------------------------
function NoteOffEvent:set_pitch(pitch)
   assert(type(pitch) == 'string' or type(pitch) == 'number', "'pitch' must be a string or a number")
   assert(Util.get_pitch(pitch), "Invalid 'pitch' value: "..pitch)
   self.pitch = pitch
   self.build_data()
   return self
end

-------------------------------------------------
-- Sets NoteOffEvent's velocity
--
-- @number velocity how quickly the note should stop.
-- Values from 0-100.
--
-- @return 	NoteOffEvent with new velocity
-------------------------------------------------
function NoteOffEvent:set_velocity(velocity)
   assert(type(velocity) == 'number' and velocity >= 0 and velocity <= 100, "'velocity' must be an integer from 0 to 100")
   self.velocity = Util.convert_velocity(velocity)
   self.build_data()
   return self
end

-------------------------------------------------
-- Sets NoteOffEvent's channel
--
-- @number channel MIDI channel # (1-16).
--
-- @return 	NoteOffEvent with new channel
-------------------------------------------------
function NoteOffEvent:set_channel(channel)
   assert(type(channel) == 'number' and channel >= 1 and channel <= 16, "'channel' must be an integer from 1 to 16")
   self.channel = channel
   self.build_data()
   return self
end

-------------------------------------------------
-- Sets NoteOffEvent's timestamp
--
-- @number timestamp value.
--
-- @return 	NoteOffEvent with new timestamp
-------------------------------------------------
function NoteOffEvent:set_timestamp(timestamp)
   assert(type(timestamp) == 'number' and timestamp >= 0, "'timestamp' must be a positive integer representing the explicit number of ticks")
   self.timestamp = timestamp
   self.build_data()
   return self
end

-------------------------------------------------
-- Gets pitch of NoteOffEvent
--
-- @return 	NoteOffEvent's pitch value
-------------------------------------------------
function NoteOffEvent:get_pitch()
   return self.pitch
end

-------------------------------------------------
-- Gets velocity of NoteOffEvent
--
-- @return 	NoteOffEvent's velocity value
-------------------------------------------------
function NoteOffEvent:get_velocity()
   return Util.revert_velocity(self.velocity)
end

-------------------------------------------------
-- Gets channel # of NoteOffEvent
--
-- @return 	NoteOffEvent's channel value
-------------------------------------------------
function NoteOffEvent:get_channel()
   return self.channel
end

-------------------------------------------------
-- Gets timestamp of NoteOffEvent
--
-- @return  NoteOffEvent's timestamp value
-------------------------------------------------
function NoteOffEvent:get_timestamp()
   return self.timestamp
end

return NoteOffEvent
