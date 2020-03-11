-------------------------------------------------
-- Abstraction of MIDI Note On and Note Off events. Handles both.
--
-- @classmod NoteEvent
-- @author Pedro Alves Valentim
-- @license MIT
-- @see Limitations_of_NoteEvent.md
-------------------------------------------------

local Constants = require('LuaMidi.Constants')
local Util = require('LuaMidi.Util')
local ArbitraryEvent = require('LuaMidi.ArbitraryEvent')

local NoteEvent = {}

-------------------------------------------------
--- Functions
-- @section functions
-------------------------------------------------

-------------------------------------------------
-- Creates a new NoteEvent. Receives a `fields` table as
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
--			<td>string, number or array</td>
--			<td>Note (or array of notes) to be triggered. Can be a string or valid MIDI note code.  Format for string is <code>C#4</code>.</td>
--		</tr>
--		<tr bgcolor="#dddddd">
--			<td><b>duration</b></td>
--			<td>string or number</td>
--			<td>
--				How long the note should sound.
--				<ul>
--					<li><code>1</code>  : whole</li>
--					<li><code>2</code>  : half</li>
--					<li><code>d2</code> : dotted half</li>
--					<li><code>4</code>  : quarter</li>
--					<li><code>d4</code> : dotted quarter</li>
--					<li><code>8</code>  : eighth</li>
--					<li><code>8t</code> : eighth triplet</li>
--					<li><code>d8</code> : dotted eighth</li>
--					<li><code>16</code> : sixteenth</li>
--					<li><code>Tn</code> : where n is an explicit number of ticks</li>
--				</ul>
--				If an array of durations is passed then the sum of the durations will be used.
--          Default: <code>4</code>
--			</td>
--		</tr>
--		<tr>
--			<td><b>rest</b></td>
--			<td>string or number</td>
--			<td>Rest before starting the note.  Takes same values as <b>duration</b>. Default: <code>0</code></td>
--		</tr>
--		<tr bgcolor="#dddddd">
--          <td><b>velocity</b></td>
--			<td>number</td>
--			<td>How loud the note should sound, values 0-100.  Default: <code>50</code></td>
--		</tr>
--		<tr>
--			<td><b>sequential</b></td>
--			<td>boolean</td>
--			<td>If <code>true</code> then array of pitches will be played sequentially as opposed to simulatanously.  Default: <code>false</code></td>
--		</tr>
--		<tr bgcolor="#dddddd">
--			<td><b>repetition</b></td>
--			<td>number</td>
--			<td>How many times this event should play. Default: <code>1</code></td>
--		</tr>
--		<tr>
--			<td><b>channel</b></td>
--			<td>number</td>
--			<td>MIDI channel to use. Default: <code>1</code></td>
--		</tr>
--	</tbody>
--</table>
--
-- **Note:** `pitch` is the only required field
--
-- @param fields a table containing NoteEvent's proprieties
--
-- @return 	new NoteEvent object 
-------------------------------------------------
function NoteEvent.new(fields)
   assert(type(fields.pitch) == 'string' or type(fields.pitch) == 'number' or type(fields.pitch) == 'table', "'pitch' must be a string, a number or an array")
   if type(fields.pitch) == 'string' or type(fields.pitch) == 'number' then
      assert(Util.get_pitch(fields.pitch), "Invalid 'pitch' value: "..fields.pitch)
      fields.pitch = {fields.pitch}
   elseif #fields.pitch == 1 then
      assert(Util.get_pitch(fields.pitch[1]), "Invalid 'pitch' value: "..fields.pitch[1])
   end
   local self = {
      type = 'note',
      pitch = fields.pitch,
      rest = fields.rest,
      duration = fields.duration,
      sequential = fields.sequential,
      velocity = fields.velocity,
      channel = fields.channel,
      repetition = fields.repetition,
   }
   if self.duration ~= nil then
      assert(type(self.duration) == 'string' or (type(self.duration) == 'number' and self.duration >= 0), "'duration' must be a string or a number")
   else
      self.duration = '4'
   end
   if self.rest ~= nil then
      assert(type(self.rest) == 'string' or type(self.rest) == 'number', "'rest' must be a string or a number")
   else
      self.rest = 0
   end
   if self.velocity ~= nil then
      assert(type(self.velocity) == 'number' and self.velocity >= 0 and self.velocity <= 100, "'velocity' must be an integer from 0 to 100")
   else
      self.velocity = 50
   end
   if self.sequential ~= nil then
      assert(type(self.sequential) == 'boolean', "'sequential' must be a boolean")
   else
      self.sequential = false
   end
   if self.repetition ~= nil then
      assert(type(self.repetition) == 'number' and self.repetition >= 1, "'repetition' must be a positive integer")
   else
      self.repetition = 1
   end
   if self.channel ~= nil then
      assert(type(self.channel) == 'number' and self.channel >= 1 and self.channel <= 16, "'channel' must be an integer from 1 to 16")
   else
      self.channel = 1
   end
   self.velocity = Util.convert_velocity(self.velocity)
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
   self.build_data = function()
      self.data = {}
      local tick_duration = self.get_tick_duration(self.duration, 'note')
      local rest_duration = self.get_tick_duration(self.rest, 'rest')
      local note_on, note_off
      if not self.sequential then
         for j=1, self.repetition do
            for i=1, #self.pitch do
               local p = self.pitch[i]
               local fields = {}
               local data
               if i == 1 then
                  data = Util.num_to_var_length(rest_duration)
                  data[#data+1] = Util.get_note_on_status(self.channel)
                  data[#data+1] = Util.get_pitch(p)
                  data[#data+1] = self.velocity
               else
                  data = {0, Util.get_pitch(p), self.velocity}
               end
               fields.data = data
               note_on = ArbitraryEvent.new(fields)
               self.data = Util.table_concat(self.data, note_on.data)
            end
            for i=1, #self.pitch do
               local p = self.pitch[i]
               local fields = {}
               local data
               if i == 1 then
                  data = Util.num_to_var_length(tick_duration)
                  data[#data+1] = Util.get_note_off_status(self.channel)
                  data[#data+1] = Util.get_pitch(p)
                  data[#data+1] = self.velocity
               else
                  data = {0, Util.get_pitch(p), self.velocity}
               end
               fields.data = data
               note_off = ArbitraryEvent.new(fields)
               self.data = Util.table_concat(self.data, note_off.data)
            end
         end
      else
         for j=1, self.repetition do
            for i=1, #self.pitch do
               local p = self.pitch[i]
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
               dataOn[#dataOn+1] = Util.get_note_on_status(self.channel)
               dataOn[#dataOn+1] = Util.get_pitch(p)
               dataOn[#dataOn+1] = self.velocity
               fieldsOn.data = dataOn
               note_on = ArbitraryEvent.new(fieldsOn)
               
               local dataOff = Util.num_to_var_length(tick_duration)
               dataOff[#dataOff+1] = Util.get_note_off_status(self.channel)
               dataOff[#dataOff+1] = Util.get_pitch(p)
               dataOff[#dataOff+1] = self.velocity
               fieldsOff.data = dataOff
               note_off = ArbitraryEvent.new(fieldsOff)
               
               self.data = Util.table_concat(self.data, dataOn)
               self.data = Util.table_concat(self.data, dataOff)
            end
         end
      end
   end
   self.build_data()
   return setmetatable(self, { __index = NoteEvent })
end

-------------------------------------------------
--- Methods
-- @section methods
-------------------------------------------------

-------------------------------------------------
-- Prints event's data in a human-friendly style
-------------------------------------------------
function NoteEvent:print()
   local function quote(str)
      if not tonumber(str:sub(1,1)) then
         return "'"..str.."'"
      end
      return str
   end
   local pitch = self.pitch
   if #self.pitch > 0 then
      pitch = "{ "
      for i=1, #self.pitch-1 do
         pitch = pitch..quote(self.pitch[i])
         pitch = pitch..", "
      end
      pitch = pitch..quote(self.pitch[#self.pitch])
      pitch = pitch.." }"
   end
   local str = string.format("Pitch:\t\t%s\n", tostring(pitch))
   str = str..string.format("Duration:\t%s\n", tostring(self.duration))
   str = str..string.format("Rest:\t\t%s\n", tostring(self.rest))
   str = str..string.format("Velocity:\t%d\n", tostring(self.velocity))
   str = str..string.format("Sequential:\t%s\n", tostring(self.sequential))
   str = str..string.format("Repetition:\t%d\n", tostring(self.repetition))
   str = str..string.format("Channel:\t%d", tostring(self.channel))
   print("\nClass / Type:\tNoteEvent / '"..self.type.."'")
   print(str)
end

-------------------------------------------------
-- Sets NoteEvent's pitch
--
-- @param pitch takes the same values as the pitch
-- field passed to the constructor.
--
-- @return 	NoteEvent with new pitch
-------------------------------------------------
function NoteEvent:set_pitch(pitch)
   assert(type(pitch) == 'string' or type(pitch) == 'number' or type(pitch) == 'table', "'pitch' must be a string, a number or an array")
   if type(pitch) == 'string' or type(pitch) == 'number' then
      assert(Util.get_pitch(pitch), "Invalid 'pitch' value: "..pitch)
      pitch = {pitch}
   elseif #pitch == 1 then
      assert(Util.get_pitch(pitch[1]), "Invalid 'pitch' value: "..pitch[1])
   end
   self.pitch = pitch
   self.build_data()
   return self
end

-------------------------------------------------
-- Sets NoteEvent's duration
--
-- @param duration takes the same values as the
-- duration field passed to the constructor.
--
-- @return 	NoteEvent with new duration
-------------------------------------------------
function NoteEvent:set_duration(duration)
   assert(type(duration) == 'string' or type(duration) == 'number', "'duration' must be a string or a number")
   self.duration = duration
   self.build_data()
   return self
end

-------------------------------------------------
-- Sets NoteEvent's rest
--
-- @param rest takes the same values as the
-- rest field passed to the constructor.
--
-- @return 	NoteEvent with new rest
-------------------------------------------------
function NoteEvent:set_rest(rest)
   assert(type(rest) == 'string' or type(rest) == 'number', "'rest' must be a string or a number")
   self.rest = rest
   self.build_data()
   return self
end

-------------------------------------------------
-- Sets NoteEvent's velocity
--
-- @number velocity loudness of the note sound.
-- Values from 0-100.
--
-- @return 	NoteEvent with new velocity
-------------------------------------------------
function NoteEvent:set_velocity(velocity)
   assert(type(velocity) == 'number' and velocity >= 0 and velocity <= 100, "'velocity' must be an integer from 0 to 100")
   self.velocity = Util.convert_velocity(velocity)
   self.build_data()
   return self
end

-------------------------------------------------
-- Sets NoteEvent's sequential property
--
-- @bool sequential `true` to play the pitches
-- (if `pitch` is an array) sequentially.
--
-- @return 	NoteEvent with new sequential property
-------------------------------------------------
function NoteEvent:set_sequential(sequential)
   assert(type(sequential) == 'boolean', "'sequential' must be a boolean")
   self.sequential = sequential
   self.build_data()
   return self
end

-------------------------------------------------
-- Sets NoteEvent's repetition
--
-- @number repetition number of times this NoteEvent
-- will be repeated.
--
-- @return 	NoteEvent with new repetition
-------------------------------------------------
function NoteEvent:set_repetition(repetition)
   assert(type(repetition) == 'number' and repetition >= 1, "'repetition' must be a positive integer")
   self.repetition = repetition
   self.build_data()
   return self
end

-------------------------------------------------
-- Sets NoteEvent's channel
--
-- @number channel MIDI channel # (1-16).
--
-- @return 	NoteEvent with new channel
-------------------------------------------------
function NoteEvent:set_channel(channel)
   assert(type(channel) == 'number' and channel >= 1 and channel <= 16, "'channel' must be an integer from 1 to 16")
   self.channel = channel
   self.build_data()
   return self
end

-------------------------------------------------
-- Gets pitch(es) of NoteEvent
--
-- @return 	NoteEvent's pitch value
-------------------------------------------------
function NoteEvent:get_pitch()
   return self.pitch
end

-------------------------------------------------
-- Gets duration of NoteEvent
--
-- @return 	NoteEvent's duration value
-------------------------------------------------
function NoteEvent:get_duration()
   return self.duration
end

-------------------------------------------------
-- Gets rest duration of NoteEvent
--
-- @return 	NoteEvent's rest value
-------------------------------------------------
function NoteEvent:get_rest()
   return self.rest
end

-------------------------------------------------
-- Gets velocity of NoteEvent
--
-- @return 	NoteEvent's velocity value
-------------------------------------------------
function NoteEvent:get_velocity()
   return Util.revert_velocity(self.velocity)
end

-------------------------------------------------
-- Gets sequentiallity of NoteEvent
--
-- @return 	NoteEvent's sequential value
-------------------------------------------------
function NoteEvent:get_sequential()
   return self.sequential
end

-------------------------------------------------
-- Gets repetition value of NoteEvent
--
-- @return 	NoteEvent's repetition value
-------------------------------------------------
function NoteEvent:get_repetition()
   return self.repetition
end

-------------------------------------------------
-- Gets channel # of NoteEvent
--
-- @return 	NoteEvent's channel value
-------------------------------------------------
function NoteEvent:get_channel()
   return self.channel
end

return NoteEvent
