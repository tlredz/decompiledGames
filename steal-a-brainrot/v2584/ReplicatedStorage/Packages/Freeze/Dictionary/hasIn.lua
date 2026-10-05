local getIn = require(script.Parent.Parent.utils.getIn)
local None = require(script.Parent.Parent.None)

local function hasIn(p, p2)
	return getIn(p, p2, None) ~= None
end

return hasIn