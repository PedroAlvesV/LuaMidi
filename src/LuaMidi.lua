-------------------------------------------------
-- LuaMidi Library Class
-- 
-- @classmod LuaMidi
-- @author Pedro Alves
-- @license MIT
-------------------------------------------------

local LuaMidi = {}

LuaMidi.Constants = require 'LuaMidi.Constants'
LuaMidi.Chunk = require 'LuaMidi.Chunk'
LuaMidi.MetaEvent = require 'LuaMidi.MetaEvent'
LuaMidi.NoteEvent = require 'LuaMidi.NoteEvent'
LuaMidi.NoteOffEvent = require 'LuaMidi.NoteOffEvent'
LuaMidi.NoteOnEvent = require 'LuaMidi.NoteOnEvent'
LuaMidi.ProgramChangeEvent = require 'LuaMidi.ProgramChangeEvent'
LuaMidi.Track = require 'LuaMidi.Track'
LuaMidi.Util = require 'LuaMidi.Util'
LuaMidi.Writer = require 'LuaMidi.Writer'

return LuaMidi
