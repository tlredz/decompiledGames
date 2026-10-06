local parent = script.Parent.Parent
require(parent.Types)
local ExternalDebug = require(parent.ExternalDebug)
local deriveScopeImpl = require(parent.Memory.deriveScopeImpl)

local function innerScope(list, ...)
	local v = deriveScopeImpl(list, ...)
	table.insert(list, v)
	table.insert(v, function()
		local index = table.find(list, v)

		if index ~= nil then
			table.remove(list, index)
		end
	end)
	ExternalDebug.trackScope(v)
	return v
end

return innerScope