local LuaMidi = require ('LuaMidi')
local Writer = LuaMidi.Writer

local tracks = LuaMidi.get_MIDI_tracks('midi files/C Major Scale.mid')

local writer = Writer.new(tracks)
--writer:stdout()
writer:save_MIDI('test', 'midi files')
