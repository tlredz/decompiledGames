local remove = require(script.Parent.Parent:FindFirstChild("remove"))
local deprecationWarning = require(script.Parent.Parent.Parent.utils.deprecationWarning)

local function removeIndex(p, p2: number)
	deprecationWarning("List." .. script.Name, "List.remove")
	return remove(p, p2)
end

return removeIndex