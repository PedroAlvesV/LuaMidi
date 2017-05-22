# LuaMidi ♫ – The Lua library to read and write MIDI files

<p align="justify"><strong>LuaMidi ♫</strong> is the pure Lua library to reading and writing MIDI files, with friendly API. As it provides MIDI data's total abstraction, it doesn't require the user to concern about technical stuff, such as delta time and NoteOn/NoteOff signals. Its methods are intuitive and its objects' data are completely human-readable.</p>

You can check the docs at [the wiki](https://github.com/PedroAlvesV/LuaMidi/wiki).  
Please, publish an [issue](https://github.com/PedroAlvesV/LuaMidi/issues), if you find any.  
This library doesn't have **any** dependencies.  


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

-- Table with notes as strings (must specify octave)
local notes = {'C3', 'D3', 'E3', 'F3', 'G3', 'A3', 'B3', 'C4'}

-- Adds notes to Track
track:add_events(NoteEvent.new({pitch = notes, sequential = true}))

-- Creates Writer passing Track
local writer = Writer.new(track)

-- Writes MIDI file called "C Major Scale.mid"
writer:save_MIDI('C Major Scale')
```

Even though the above example creates a working MIDI file, it's encouragable to add some metadata to MIDI files. A more complete version of this code can be found here: [src/c_major_scale.lua](https://github.com/PedroAlvesV/LuaMidi/tree/master/src/c_major_scale.lua)

This short script works over the basics of LuaMidi. Initially, it creates a `Track` object. Then, it creates an array(`notes`) with the notes as strings. After that, it adds this array to a new `NoteEvent`, also passing `true` as `sequential` field to indicate the notes won't be played at the same time. Once the track is ready, it creates a `Writer` object passing the track as parameter. With all tracks' data, the `Writer` can produce a working MIDI file.

You can check the complete documentation at [the wiki](https://github.com/PedroAlvesV/LuaMidi/wiki).

### Example

Stairway to Heaven (intro)
```lua
local LuaMidi = require ('LuaMidi')
local Track = LuaMidi.Track
local NoteEvent = LuaMidi.NoteEvent
local Writer = LuaMidi.Writer

local track = Track.new("Intro")
track:add_copyright("(C) Led Zeppelin")
track:add_instrument_name("Acoustic Guitar")

local function note(pitch, duration)
   return NoteEvent.new({pitch = pitch, duration = tostring(duration)})
end

local A3 = note('A3')
local C4 = note('C4')
local E4 = note('E4')
local A4 = note('A4')
local Ab3_B4 = note({'G#3', 'B4'})
local B4 = note('B4')
local G3_C5 = note({'G3', 'C5'})
local C5 = note('C5')
local Gb3_Gb4 = note({'F#3', 'F#4'})
local D4 = note('D4')
local Gb4 = note('F#4')
local F3_E4 = note({'F3', 'E4'})
local long_C4 = note('C4', 2)

local Am = {'A2', 'E3', 'A3', 'C4'}

local chord_GB = note({'B2', 'D3', 'G3', 'B3'})
local chord_Am = note(Am)
local long_chord_Am = note(Am, 1)

track:add_events({
   A3, C4, E4, A4, Ab3_B4, E4, C4, B4,
   G3_C5, E4, C4, C5, Gb3_Gb4, D4, A3,
   Gb4, F3_E4, C4, A3, long_C4, E4, C4, A3,
   chord_GB, chord_Am, long_chord_Am
})

local writer = Writer.new(track)
writer:save_MIDI('stairway_to_heaven', 'midi files')
```

The produced MIDI file can be downloaded here: [stairway_to_heaven.mid](https://github.com/PedroAlvesV/LuaMidi/tree/master/src/midi%20files/stairway_to_heaven.mid)

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
* Inspired by [♬ MidiWriterJS](https://github.com/grimmdude/MidiWriterJS), by [Garret Grimm](http://grimmdude.com)
