local filter = require(script.Parent.filter)

local function filterNot(p, callback)
	return filter(p, function(p2, p3)
		return not callback(p2, p3)
	end)
end

return filterNot