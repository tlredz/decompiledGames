local push = require(script.Parent.Parent.push)
local deprecationWarning = require(script.Parent.Parent.Parent.utils.deprecationWarning)

local function append(p, ...)
	deprecationWarning("List." .. script.Name, "List.push")
	return push(p, ...)
end

return append