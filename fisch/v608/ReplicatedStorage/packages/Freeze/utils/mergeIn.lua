local updateIn = require(script.Parent.updateIn)
local merge = require(script.Parent.merge)
return function(p, p2, ...)
	local v = { ... }
	return updateIn(p, p2, function(p3)
		return merge(p3, table.unpack(v))
	end, {})
end