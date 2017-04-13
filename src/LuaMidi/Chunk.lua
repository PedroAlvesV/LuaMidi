local Chunk = {}

function Chunk.new(fields)
   local self = {
      type = fields.type,
      data = fields.data,
      size = {0, 0, 0, #fields.data},
   }
   return setmetatable(self, { __index = Chunk })
end

return Chunk