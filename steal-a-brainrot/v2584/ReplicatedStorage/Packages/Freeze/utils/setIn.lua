local updateIn = require(script.Parent.updateIn)
local None = require(script.Parent.Parent.None)
return function(p, p2, p3)
	return updateIn(p, p2, function()
		return p3
	end, None)
end