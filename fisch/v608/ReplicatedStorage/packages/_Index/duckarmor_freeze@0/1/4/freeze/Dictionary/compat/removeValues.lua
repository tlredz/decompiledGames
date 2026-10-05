local removeValue = require(script.Parent.Parent.removeValue)
local deprecationWarning = require(script.Parent.Parent.Parent.utils.deprecationWarning)

local function removeValues(p, ...)
	deprecationWarning("Dictionary." .. script.Name, "Dictionary.removeValue")
	return removeValue(p, ...)
end

return removeValues