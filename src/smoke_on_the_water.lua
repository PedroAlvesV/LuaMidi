local LuaMidi = require ('LuaMidi')
local Track = LuaMidi.Track
local NoteEvent = LuaMidi.NoteEvent
local Writer = LuaMidi.Writer

local track = Track.new()

local function chord(array, duration)
   duration = tostring(duration)
   return NoteEvent.new({pitch = array, duration = duration})
end

local G5 = {'D3', 'G3'}
local Bb5 = {'F3', 'A#3'}
local C5 = {'G3', 'C4'}
local Db5 = {'G#3', 'C#4'}

local std_G5 = chord(G5)
local short_G5 = chord(G5, 8)
local long_G5 = chord(G5, 2)

local std_Bb5 = chord(Bb5)

local std_C5 = chord(C5)
local dotted_C5 = chord(C5, 'd4')
local long_C5 = chord(C5, 2)

local short_Db5 = chord(Db5, 8)

track:add_event({
   std_G5, std_Bb5, dotted_C5,
   std_G5, std_Bb5, short_Db5, long_C5,
   std_G5, std_Bb5, dotted_C5,
   std_Bb5, std_G5
})

local writer = Writer.new({track})
writer:save_MIDI('Smoke on the Water', 'midi files')
