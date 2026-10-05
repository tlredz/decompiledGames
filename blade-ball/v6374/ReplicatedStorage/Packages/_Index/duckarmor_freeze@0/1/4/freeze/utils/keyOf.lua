local findKey = require(script.Parent.findKey)
local is = require(script.Parent.is)
return function(p, p2)
	return findKey(p, function(p3)
		return is(p3, p2)
	end)
end