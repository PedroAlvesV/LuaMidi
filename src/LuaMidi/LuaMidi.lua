-------------------------------------------------
-- LuaMidi Library Class
-- 
-- @classmod LuaMidi
-- @author Pedro Alves
-- @license MIT
-------------------------------------------------

local LuaMidi = {}

LuaMidi.Constants = require('LuaMidi.Constants')
LuaMidi.Track = require('LuaMidi.Track')
LuaMidi.Chunk = require('LuaMidi.Chunk')
LuaMidi.NoteEvent = require('LuaMidi.NoteEvent')
LuaMidi.NoteOffEvent = require('LuaMidi.NoteOffEvent')
LuaMidi.NoteOnEvent = require('LuaMidi.NoteOnEvent')
LuaMidi.MetaEvent = require('LuaMidi.MetaEvent')
LuaMidi.ProgramChangeEvent = require('LuaMidi.ProgramChangeEvent')
LuaMidi.Writer = require('LuaMidi.Writer')

return LuaMidi