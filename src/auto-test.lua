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
      for i=1, #tracks do
         if show_log then
            local events = tracks[i]:get_events()
            print("Track #"..i)
            print("\tName:   ",tracks[i]:get_name())
            print("\tCopyright:",tracks[i]:get_copyright())
            print("\tInstrument:",tracks[i]:get_instrument_name())
            print("\tLyric:   ",tracks[i]:get_lyric())
            print("\tText:   ",tracks[i]:get_text())
            print("\tMarker:   ",tracks[i]:get_marker())
            print("\tCue Point:",tracks[i]:get_cue_point())
            for j=1, #events do
               events[j]:print()
            end
         end
      end
   end
end

print("\nNo errors, not stuck.")
