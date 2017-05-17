local filenames = {
   'hot_cross_buns',
   'c_major_scale',
   'stairway_to_heaven',
   'smoke_on_the_water',
}

local show_log = not (arg[1] == '--quiet' or arg[1] == '-q')

local run
for _, name in ipairs(filenames) do
   if show_log then
      print("Executing", name..".lua")
   end
   run = os.execute('lua '..name..'.lua')
   if not run then break end
end

if run then
   local LuaMidi = require('LuaMidi')
   for _, name in ipairs(filenames) do
      if show_log then
         print("\n"..name..".mid")
      end
      local tracks = LuaMidi.get_MIDI_tracks('midi files/'..name..'.mid')
      for i, track in ipairs(tracks) do
         if show_log then
            print("Track #"..i)
            print("\tName:   ",track:get_name())
            print("\tCopyright:",track:get_copyright())
            print("\tInstrument:",track:get_instrument_name())
            print("\tLyric:   ",track:get_lyric())
            print("\tText:   ",track:get_text())
            print("\tMarker:   ",track:get_marker())
            print("\tCue Point:",track:get_cue_point())
            print()
         end
      end
   end
end

print("No errors, not stuck.")
