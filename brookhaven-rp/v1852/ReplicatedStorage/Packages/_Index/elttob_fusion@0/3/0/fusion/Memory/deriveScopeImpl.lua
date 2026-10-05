local parent = script.Parent.Parent
require(parent.Types)
local merge = require(parent.Utility.merge)
local scopePool = require(parent.Memory.scopePool)

local function deriveScopeImpl(p, p2, ...)
	local metatable = getmetatable(p)

	if p2 ~= nil then
		metatable = table.clone(metatable)
		metatable.__index = merge(true, {}, metatable.__index, merge(false, {}, p2, ...))
	end

	return (setmetatable(scopePool.reuseAny() or {}, metatable))
end

return deriveScopeImpl