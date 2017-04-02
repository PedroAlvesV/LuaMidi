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
      repeat = fields.repeat or 1,
   }
   function convert_velocity(velocity)
      -- must test
      if velocity > 100 then
         velocity = 100
      end
      return math.round(velocity / 100 * 127)
   end
   self.velocity = convert_velocity(self.velocity)
   self.build_data = function()
      -- TODO
   end
   self.build_data()
   return setmetatable(self, { __index = NoteEvent })
end
   
function NoteEvent:get_tick_duration(duration, type)
   -- TODO
end

function NoteEvent:get_duration_multiplier(duration, type)
   if duration == 0 then
      return 0
   elseif duration == 1 then
      return 4
   elseif duration == 2 then
      return 2
   elseif duration == 'd2' then
      return 3
   elseif duration == 4 then
      return 1
   elseif duration == 'd4' then
      return 1.5
   elseif duration == 8 then
      return 0.5
   elseif duration == '8t' then
      return 0.33
   elseif duration == 'd8' then
      return 0.75
   elseif duration == 16 then
      return 0.25
   else
      if type == 'note' then
         return 1
      end
      return 0
   end
end

function NoteEvent:get_NoteOn_Status()
   return 144 + self.channel - 1
end

function NoteEvent:get_NoteOff_Status()
   return 128 + self.channel - 1
end

return NoteEvent