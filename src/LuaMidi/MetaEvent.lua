-------------------------------------------------
-- Abstraction of MIDI Meta Event representation
-- <p>**Note:** This object should not be created
-- by the user.
--
-- @classmod MetaEvent
-- @author Pedro Alves
-- @license MIT
-------------------------------------------------

local Constants = require('LuaMidi.Constants')
local Util = require('LuaMidi.Util')

local MetaEvent = {}

-------------------------------------------------
-- Creates a new MetaEvent
--
-- @param fields a table containing the MetaEvent's data in a data field
--
-- @return 	new MetaEvent object
-------------------------------------------------
function MetaEvent.new(fields)
   local data = Util.num_to_var_length(0x00)
   data = Util.table_concat(data, {Constants.META_EVENT_ID})
   data = Util.table_concat(data, fields.data)
   local self = {
      type = 'meta',
      data = data,
   }
   return setmetatable(self, { __index = MetaEvent })
end

return MetaEvent
