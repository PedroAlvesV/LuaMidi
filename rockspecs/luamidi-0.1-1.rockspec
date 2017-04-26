package = "LuaMidi"
version = "0.1-1"
source = {
   url = "git+https://github.com/PedroAlvesV/LuaMidi.git"
}
description = {
   summary = "LuaMidi ♫ – A library to write MIDI programmatically in Lua.",
   detailed = [[
	LuaMidi is a library to write MIDI programmatically in Lua. It is designed to produce from simple single-track note-only MIDI, to complete multi-track, featuring arpeggios and chords, with any metadata embedded MIDI files.
   ]],
   homepage = "https://github.com/PedroAlvesV/LuaMidi",
   license = "MIT"
}
build = {
   type = "builtin",
   modules = {
      LuaMidi = "src/LuaMidi.lua",
      ["LuaMidi.Chunk"] = "src/LuaMidi/Chunk.lua",
      ["LuaMidi.Constants"] = "src/LuaMidi/Constants.lua",
      ["LuaMidi.MetaEvent"] = "src/LuaMidi/MetaEvent.lua",
      ["LuaMidi.NoteEvent"] = "src/LuaMidi/NoteEvent.lua",
      ["LuaMidi.NoteOffEvent"] = "src/LuaMidi/NoteOffEvent.lua",
      ["LuaMidi.NoteOnEvent"] = "src/LuaMidi/NoteOnEvent.lua",
      ["LuaMidi.ProgramChangeEvent"] = "src/LuaMidi/ProgramChangeEvent.lua",
      ["LuaMidi.Track"] = "src/LuaMidi/Track.lua",
      ["LuaMidi.Util"] = "src/LuaMidi/Util.lua",
      ["LuaMidi.Writer"] = "src/LuaMidi/Writer.lua",
   }
}
