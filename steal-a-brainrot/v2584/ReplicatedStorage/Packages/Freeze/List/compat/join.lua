local merge = require(script.Parent.Parent.merge)
local deprecationWarning = require(script.Parent.Parent.Parent.utils.deprecationWarning)

local function join(...)
	deprecationWarning("List." .. script.Name, "List.merge")
	return merge(...)
end

return join