-------------------------------------------------
-- Abstraction of MIDI Note On event.
-- <p> Useful for arrangements `NoteEvent` can't
-- be produce.
--
-- @classmod NoteOnEvent
-- @author Pedro Alves Valentim
-- @license MIT
-- @see Limitations_of_NoteEvent.md
-------------------------------------------------

local Constants = require('LuaMidi.Constants')
local Util = require('LuaMidi.Util')
local ArbitraryEvent = require('LuaMidi.ArbitraryEvent')

local NoteOnEvent = {}

-------------------------------------------------
--- Functions
-- @section functions
-------------------------------------------------

-------------------------------------------------
-- Creates a new NoteOnEvent. Receives a `fields` table as
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
--			<td>Note to be set on. Can be a string or valid MIDI note code.  Format for string is <code>C#4</code>.</td>
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
--			<td>How loud the note should sound, values 0-100.  Default: <code>50</code></td>
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
-- @param fields a table containing NoteOnEvent's properties
--
-- @return 	new NoteOnEvent object
-------------------------------------------------
function NoteOnEvent.new(fields)
   assert(type(fields.pitch) == 'string' or type(fields.pitch) == 'number', "'pitch' must be a string or a number")
   assert(Util.get_pitch(fields.pitch), "Invalid 'pitch' value: "..fields.pitch)
   local self = {
      type = 'note_on',
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
      data[#data+1] = Util.get_note_on_status(self.channel)
      data[#data+1] = Util.get_pitch(self.pitch)
      data[#data+1] = self.velocity
      
      local note_on = ArbitraryEvent.new({data = data})
      self.data = Util.table_concat(self.data, note_on.data)
      
   end
   
   self.build_data()
   return setmetatable(self, { __index = NoteOnEvent })
end

-------------------------------------------------
--- Methods
-- @section methods
-------------------------------------------------

-------------------------------------------------
-- Prints event's data in a human-friendly style
-------------------------------------------------
function NoteOnEvent:print()
   local str = string.format("Pitch:\t\t%s\n", tostring(self.pitch))
   str = str..string.format("Velocity:\t%d\n", tostring(self.velocity))
   str = str..string.format("Channel:\t%d\n", tostring(self.channel))
   str = str..string.format("Timestamp:\t%d", tostring(self.timestamp))
   print("\nClass / Type:\tNoteOnEvent / '"..self.type.."'")
   print(str)
end

-------------------------------------------------
-- Sets NoteOnEvent's pitch
--
-- @param pitch takes the same values as the pitch
-- field passed to the constructor.
--
-- @return 	NoteOnEvent with new pitch
-------------------------------------------------
function NoteOnEvent:set_pitch(pitch)
   assert(type(pitch) == 'string' or type(pitch) == 'number', "'pitch' must be a string or a number")
   assert(Util.get_pitch(pitch), "Invalid 'pitch' value: "..pitch)
   self.pitch = pitch
   self.build_data()
   return self
end

-------------------------------------------------
-- Sets NoteOnEvent's velocity
--
-- @number velocity loudness of the note sound.
-- Values from 0-100.
--
-- @return 	NoteOnEvent with new velocity
-------------------------------------------------
function NoteOnEvent:set_velocity(velocity)
   assert(type(velocity) == 'number' and velocity >= 0 and velocity <= 100, "'velocity' must be an integer from 0 to 100")
   self.velocity = Util.convert_velocity(velocity)
   self.build_data()
   return self
end

-------------------------------------------------
-- Sets NoteOnEvent's channel
--
-- @number channel MIDI channel # (1-16).
--
-- @return 	NoteOnEvent with new channel
-------------------------------------------------
function NoteOnEvent:set_channel(channel)
   assert(type(channel) == 'number' and channel >= 1 and channel <= 16, "'channel' must be an integer from 1 to 16")
   self.channel = channel
   self.build_data()
   return self
end

-------------------------------------------------
-- Sets NoteOnEvent's timestamp
--
-- @number timestamp value.
--
-- @return 	NoteOnEvent with new timestamp
-------------------------------------------------
function NoteOnEvent:set_timestamp(timestamp)
   assert(type(timestamp) == 'number' and timestamp >= 0, "'timestamp' must be a positive integer representing the explicit number of ticks")
   self.timestamp = timestamp
   self.build_data()
   return self
end

-------------------------------------------------
-- Gets pitch of NoteOnEvent
--
-- @return 	NoteOnEvent's pitch value
-------------------------------------------------
function NoteOnEvent:get_pitch()
   return self.pitch
end

-------------------------------------------------
-- Gets velocity of NoteOnEvent
--
-- @return 	NoteOnEvent's velocity value
-------------------------------------------------
function NoteOnEvent:get_velocity()
   return Util.revert_velocity(self.velocity)
end

-------------------------------------------------
-- Gets channel # of NoteOnEvent
--
-- @return 	NoteOnEvent's channel value
-------------------------------------------------
function NoteOnEvent:get_channel()
   return self.channel
end

-------------------------------------------------
-- Gets timestamp of NoteOnEvent
--
-- @return  NoteOnEvent's timestamp value
-------------------------------------------------
function NoteOnEvent:get_timestamp()
   return self.timestamp
end

return NoteOnEvent
