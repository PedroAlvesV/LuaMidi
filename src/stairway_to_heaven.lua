local LuaMidi = require ('LuaMidi')
local Track = LuaMidi.Track
local NoteEvent = LuaMidi.NoteEvent
local Writer = LuaMidi.Writer

local track = Track.new()

local function note(pitch)
   return NoteEvent.new({pitch = {pitch}})
end
local function chord(array)
   return NoteEvent.new({pitch = array})
end

local A4 = note('A4')
local C5 = note('C5')
local E5 = note('E5')
local A5 = note('A5')
local Ab4_B5 = chord({'G#4', 'B5'})
local B5 = note('B5')
local G4_C6 = chord({'G4', 'C6'})
local C6 = note('C6')
local Gb4_Gb5 = chord({'F#4', 'F#5'})
local D5 = note('D5')
local Gb5 = note('F#5')
local F4_E5 = chord({'F4', 'E5'})
local long_C5 = NoteEvent.new({pitch = {'C5'}, duration = '2'})

local Am = {'A3', 'E4', 'A4', 'C5'}

local chord_GB = chord({'B3', 'D4', 'G4', 'B4'})
local chord_Am = chord(Am)
local long_chord_Am = NoteEvent.new({pitch = Am, duration = '2'})

track:add_event({
   A4, C5, E5, A5, Ab4_B5, E5, C5, B5,
   G4_C6, E5, C5, C6, Gb4_Gb5, D5, A4,
   Gb5, F4_E5, C5, A4, long_C5, E5, C5, A4,
   chord_GB, chord_Am, long_chord_Am
})

local writer = Writer.new({track})
writer:save_MIDI('stairway_to_heaven')
