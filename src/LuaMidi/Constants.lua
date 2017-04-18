local Constants = {
    HEADER_CHUNK_TYPE      = {0x4d, 0x54, 0x68, 0x64}, -- Mthd
    HEADER_CHUNK_LENGTH    = {0x00, 0x00, 0x00, 0x06}, -- Header size for SMF
    HEADER_CHUNK_FORMAT0   = {0x00, 0x00}, -- Midi Type 0 id
    HEADER_CHUNK_FORMAT1   = {0x00, 0x01}, -- Midi Type 1 id
    HEADER_CHUNK_DIVISION  = {0x00, 0x80}, -- Defaults to 128 ticks per beat
    TRACK_CHUNK_TYPE       = {0x4d, 0x54, 0x72, 0x6b}, -- MTrk,
    META_EVENT_ID          = 0xFF,
    META_TEXT_ID           = 0x01,
    META_COPYRIGHT_ID      = 0x02,
    META_TRACK_NAME_ID     = 0x03,
    META_INSTRUMENT_NAME_ID= 0x04,
    META_LYRIC_ID          = 0x05,
    META_MARKER_ID         = 0x06,
    META_CUE_POINT         = 0x07,
    META_TEMPO_ID          = 0x51,
    META_SMTPE_OFFSET      = 0x54,
    META_TIME_SIGNATURE_ID = 0x58,
    META_KEY_SIGNATURE_ID  = 0x59,
    META_END_OF_TRACK_ID   = {0x2F, 0x00},
    --NOTE_ON_STATUS         = 0x90, -- includes channel number (0)
    --NOTE_OFF_STATUS        = 0x80, -- includes channel number (0)
    PROGRAM_CHANGE_STATUS  = 0xC0, -- includes channel number (0)
    NOTES                  = {},
}

local table_notes = {
   {'C','B#'},
   {'C#','Db'},
   {'D'},
   {'D#','Eb'},
   {'E','Fb'},
   {'F','E#'},
   {'F#','Gb'},
   {'G'},
   {'G#','Ab'},
   {'A'},
   {'A#','Bb'},
   {'B','Cb'},
}

local counter = 0
for i=-1, 9 do
   -- really must test
   for tone, note in ipairs(table_notes) do
      for _, notation in ipairs(note) do
         Constants.NOTES[notation .. i] = counter
      end
      counter = counter + 1
   end
end

return Constants
