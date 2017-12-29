local bit = {}

bit.band = function(a,b) return a & b end
bit.bor = function(a,b) return a | b end
bit.lshift = function(a,b) return a << b end
bit.rshift = function(a,b) return a >> b end

return bit
