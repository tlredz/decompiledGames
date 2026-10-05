local removeValue = require(script.Parent.Parent.removeValue)
local deprecationWarning = require(script.Parent.Parent.Parent.utils.deprecationWarning)

local function removeValues(p, ...)
	deprecationWarning("List." .. script.Name, "List.removeValue")
	return removeValue(p, ...)
end

return removeValues