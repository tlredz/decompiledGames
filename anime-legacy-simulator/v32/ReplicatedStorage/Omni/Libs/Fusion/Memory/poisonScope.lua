local parent = script.Parent.Parent
require(parent.Types)
local External = require(parent.External)

local function poisonScope(list, p: string)
	local metatable = getmetatable(list)

	if typeof(metatable) == "table" and metatable._FUSION_POISONED then
		return
	end

	table.clear(list)
	setmetatable(list, {
		_FUSION_POISONED = true,
		__index = function()
			External.logError("poisonedScope", nil, p)
		end,
		__newindex = function()
			External.logError("poisonedScope", nil, p)
		end
	})
end

return poisonScope