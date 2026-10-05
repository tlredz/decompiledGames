local remove = require(script.Parent.Parent:FindFirstChild("remove"))
local deprecationWarning = require(script.Parent.Parent.Parent.utils.deprecationWarning)

local function removeKey(p, p2)
	deprecationWarning("Dictionary." .. script.Name, "Dictionary.remove")
	return remove(p, p2)
end

return removeKey