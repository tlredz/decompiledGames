local values = require(script.Parent.Parent.values)
local deprecationWarning = require(script.Parent.Parent.Parent.utils.deprecationWarning)

local function toArray(p)
	deprecationWarning("Dictionary." .. script.Name, "Dictionary.values")
	return values(p)
end

return toArray