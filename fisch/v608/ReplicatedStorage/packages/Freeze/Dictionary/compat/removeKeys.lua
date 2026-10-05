local remove = require(script.Parent.Parent:FindFirstChild("remove"))
local deprecationWarning = require(script.Parent.Parent.Parent.utils.deprecationWarning)

local function removeKeys(p, ...)
	deprecationWarning("Dictionary." .. script.Name, "Dictionary.remove")
	return remove(p, ...)
end

return removeKeys