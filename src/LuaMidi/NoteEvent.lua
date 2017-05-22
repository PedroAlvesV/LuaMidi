-------------------------------------------------
-- Abstraction of MIDI Note On and Note Off events. Handles both.
--
-- @classmod NoteEvent
-- @author Pedro Alves
-- @license MIT
-------------------------------------------------

local Constants = require('LuaMidi.Constants')
local Util = require('LuaMidi.Util')
local NoteOnEvent = require('LuaMidi.NoteOnEvent')
local NoteOffEvent = require('LuaMidi.NoteOffEvent')

local NoteEvent = {}

-------------------------------------------------
-- Creates a new NoteEvent. Receives a `fields` table as
-- parameter. This table is expected with some (or all)
-- of these fields:
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
--			<td>array</td>
--			<td>An array of notes to be triggered.  Can be a string or valid MIDI note code.  Format for string is <code>C#4</code>.</td>
--		</tr>
--		<tr bgcolor="#dddddd">
--			<td><b>duration</b></td>
--			<td>string or array</td>
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
--			</td>
--		</tr>
--		<tr>
--			<td><b>wait</b></td>
--			<td>string</td>
--			<td>How long to wait before sounding note (rest).  Takes same values as <b>duration</b>.</td>
--		</tr>
--		<tr bgcolor="#dddddd">
--			<td><b>sequential</b></td>
--			<td>boolean</td>
--			<td>If true then array of pitches will be played sequentially as opposed to simulatanously.  Default: <code>false</code></td>
--		</tr>
--		<tr>
--			<td><b>velocity</b></td>
--			<td>number</td>
--			<td>How loud the note should sound, values 1-100.  Default: <code>50</code></td>
--		</tr>
--		<tr bgcolor="#dddddd">
--			<td><b>repeat</b></td>
--			<td>number</td>
--			<td>How many times this event should be repeated. Default: <code>1</code></td>
--		</tr>
--		<tr>
--			<td><b>channel</b></td>
--			<td>number</td>
--			<td>MIDI channel to use. Default: <code>1</code></td>
--		</tr>
--	</tbody>
--</table>
--
-- @param fields a table containing NoteEvent's proprieties
--
-- @return 	new NoteEvent object
-------------------------------------------------
function NoteEvent.new(fields)
   if type(fields.pitch) == 'string' or type(fields.pitch) == 'number' then fields.pitch = {fields.pitch} end
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
   local str = string.format("Pitch:\t\t%s\nDuration:\t%s\nRest:\t\t%s\nVelocity:\t%d\nChannel:\t%d\nRepetition:\t%d\nSequential:\t%s",pitch,self.duration,self.wait,self.velocity,self.channel,self.repetition,self.sequential)
   print("\nClass / Type:\tNoteEvent / '"..self.type.."'")
   print(str)
end

function NoteEvent:set_pitch(pitch)
   if type(pitch) == 'string' or type(pitch) == 'number' then
      pitch = {pitch}
   elseif type(pitch) ~= 'table' then
      return false
   end
   self.pitch = pitch
   self.build_data()
   return self
end

function NoteEvent:set_duration(duration)
   if type(duration) == 'number' then
      duration = tostring(duration)
   elseif type(duration) ~= 'string' then
      return false
   end
   self.duration = duration
   self.build_data()
   return self
end

function NoteEvent:set_wait(wait)
   if type(wait) == 'number' then
      wait = tostring(wait)
   elseif type(wait) ~= 'string' then
      return false
   end
   self.wait = wait
   self.build_data()
   return self
end

function NoteEvent:set_velocity(velocity)
   if type(velocity) ~= 'number' then return false end
   self.velocity = self.convert_velocity(velocity)
   self.build_data()
   return self
end

function NoteEvent:set_channel(channel)
   if type(channel) ~= 'number' then return false end
   self.channel = channel
   self.build_data()
   return self
end

function NoteEvent:set_repetition(repetition)
   if type(repetition) ~= 'number' then return false end
   self.repetition = repetition
   self.build_data()
   return self
end

function NoteEvent:set_sequential(sequential)
   if type(sequential) ~= 'boolean' then return false end
   self.sequential = sequential
   self.build_data()
   return self
end

function NoteEvent:get_pitch()
   return self.pitch
end

function NoteEvent:get_duration()
   return self.duration
end

function NoteEvent:get_wait()
   return self.wait
end

function NoteEvent:get_velocity()
   return self.velocity
end

function NoteEvent:get_channel()
   return self.channel
end

function NoteEvent:get_repetition()
   return self.repetition
end

function NoteEvent:get_sequential()
   return self.sequential
end

return NoteEvent
