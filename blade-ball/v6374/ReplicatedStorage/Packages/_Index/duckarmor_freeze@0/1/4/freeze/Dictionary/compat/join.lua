local merge = require(script.Parent.Parent.merge)
local deprecationWarning = require(script.Parent.Parent.Parent.utils.deprecationWarning)

local function join(...)
	deprecationWarning("Dictionary." .. script.Name, "Dictionary.merge")
	return merge(...)
end

return join