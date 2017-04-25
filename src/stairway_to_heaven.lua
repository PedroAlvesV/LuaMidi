local LuaMidi = require ('LuaMidi')
local Track = LuaMidi.Track
local NoteEvent = LuaMidi.NoteEvent
local Writer = LuaMidi.Writer

local track = Track.new()

local function note(pitch, duration)
   return NoteEvent.new({pitch = {pitch}, duration = tostring(duration)})
end
local function chord(array, duration)
   return NoteEvent.new({pitch = array, duration = tostring(duration)})
end

local A3 = note('A3')
local C4 = note('C4')
local E4 = note('E4')
local A4 = note('A4')
local Ab3_B4 = chord({'G#3', 'B4'})
local B4 = note('B4')
local G3_C5 = chord({'G3', 'C5'})
local C5 = note('C5')
local Gb3_Gb4 = chord({'F#3', 'F#4'})
local D4 = note('D4')
local Gb4 = note('F#4')
local F3_E4 = chord({'F3', 'E4'})
local long_C4 = note('C4', 2)

local Am = {'A2', 'E3', 'A3', 'C4'}

local chord_GB = chord({'B2', 'D3', 'G3', 'B3'})
local chord_Am = chord(Am)
local long_chord_Am = chord(Am, 1)

track:add_event({
   A3, C4, E4, A4, Ab3_B4, E4, C4, B4,
   G3_C5, E4, C4, C5, Gb3_Gb4, D4, A3,
   Gb4, F3_E4, C4, A3, long_C4, E4, C4, A3,
   chord_GB, chord_Am, long_chord_Am
})

local writer = Writer.new({track})
writer:save_MIDI('Stairway to Heaven', 'midi files')
