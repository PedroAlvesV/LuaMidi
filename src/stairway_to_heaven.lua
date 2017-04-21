local LuaMidi = require ('LuaMidi')
local Track = LuaMidi.Track
local NoteEvent = LuaMidi.NoteEvent
local Writer = LuaMidi.Writer

local track = Track.new()

local function foo(pitch)
   return NoteEvent.new({pitch = {pitch}})
end
local function bar(array)
   return NoteEvent.new({pitch = array})
end

local A4 = foo('A4')
local C5 = foo('C5')
local E5 = foo('E5')
local A5 = foo('A5')
local Ab4_B5 = bar({'G#4', 'B5'})
local B5 = foo('B5')
local G4_C6 = bar({'G4', 'C6'})
local C6 = foo('C6')
local Gb4_Gb5 = bar({'F#4', 'F#5'})
local D5 = foo('D5')
local Gb5 = foo('F#5')
local F4_E5 = bar({'F4', 'E5'})
local long_C5 = NoteEvent.new({pitch = {'C5'}, duration = '2'})

local Am = {'A3', 'E4', 'A4', 'C5'}

local chord_GB = bar({'B3', 'D4', 'G4', 'B4'})
local chord_Am = bar(Am)
local long_chord_Am = NoteEvent.new({pitch = Am, duration = '2'})

track:add_event({
   A4, C5, E5, A5, Ab4_B5, E5, C5, B5,
   G4_C6, E5, C5, C6, Gb4_Gb5, D5, A4,
   Gb5, F4_E5, C5, A4, long_C5, E5, C5, A4,
   chord_GB, chord_Am, long_chord_Am
})

local writer = Writer.new({track})
writer:save_MIDI('stairway_to_heaven')
