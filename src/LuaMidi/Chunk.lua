-------------------------------------------------
-- Abstraction of MIDI Chunk representation
-- <p>**Note:** This object should not be created
-- by the user.
--
-- @classmod Chunk
-- @author Pedro Alves Valentim
-- @license MIT
-------------------------------------------------
local Chunk = {}

-------------------------------------------------
--- Functions
-- @section functions
-------------------------------------------------

-------------------------------------------------
-- Creates a new Chunk
--
-- @param fields a table containing the a data field and a type field
--
-- @return 	new Chunk object
-------------------------------------------------
function Chunk.new(fields)
   local self = {
      type = fields.type,
      data = fields.data,
      size = {0, 0, 0, #fields.data},
   }
   return setmetatable(self, { __index = Chunk })
end

return Chunk
