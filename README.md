# LuaMidi ♫

LuaMidi is a library to write MIDI programmatically in Lua.
 
Note that this is a work in progress, but can write working _**basic**_ MIDI files.

You can check the docs at [the wiki](https://github.com/PedroAlvesV/LuaMidi/wiki).

## Getting Started

### Installation

To install LuaMidi, use [LuaRocks](https://github.com/luarocks/luarocks):

```
$ luarocks install luamidi
```

### Usage

Initially, it must import the main module:

```lua
local LuaMidi = require ('LuaMidi')
```

Once it's been done, all classes are available.  
Here is an example of how to write the C Major Scale:

```lua
local LuaMidi = require ('LuaMidi')
local Track = LuaMidi.Track
local NoteEvent = LuaMidi.NoteEvent
local Writer = LuaMidi.Writer

-- Creates Track instance
local track = Track.new()

-- Adds notes to Track
track:add_event({
   NoteEvent.new({pitch = {'C3'}}),
   NoteEvent.new({pitch = {'D3'}}),
   NoteEvent.new({pitch = {'E3'}}),
   NoteEvent.new({pitch = {'F3'}}),
   NoteEvent.new({pitch = {'G3'}}),
   NoteEvent.new({pitch = {'A3'}}),
   NoteEvent.new({pitch = {'B3'}}),
   NoteEvent.new({pitch = {'C4'}}),
})

-- Creates Writer passing Track
local writer = Writer.new({track})

-- Writes MIDI file called "C Major Scale.mid"
writer:save_MIDI('C Major Scale')
```

To avoid this `NoteEvent.new(...)` repetition, here's an alternative: [src/c_major_scale.lua](src/c_major_scale.lua)

This short script works over the basics of LuaMidi. Initially, it creates a `Track` object. After that, it adds the C scale, starting on `C3` and closing on `C4`. It instanciates a `NoteEvent` object for every note. Once the track is ready, it creates a `Writer` object that, during its construction, receives a table containing all the tracks. Because it's just a scale, all events were added in a single track. With all tracks' data, the `Writer` can produce a working MIDI file.

You can check the docs at [the wiki](https://github.com/PedroAlvesV/LuaMidi/wiki).

### Example

Stairway to Heaven (intro)
```lua
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
```

The produced MIDI file can be downloaded here: [Stairway to Heaven.mid](src/midi%20files/Stairway%20to%20Heaven.mid)

## Contributing

1. Create an issue and describe your contribution
2. Fork it (https://github.com/PedroAlvesV/LuaMidi/fork)
3. Create a new branch for your contribution (`git checkout -b my-contribution`)
4. Commit your changes (`git commit -am 'New feature added'`)
5. Publish the branch (`git push origin my-contribution`)
6. Create a Pull Request
7. Done :white_check_mark:

## Credits

* Lua library written by [Pedro Alves](https://github.com/PedroAlvesV)
* Based on [♬ MidiWriterJS](https://github.com/grimmdude/MidiWriterJS) by [Garret Grimm](http://grimmdude.com)