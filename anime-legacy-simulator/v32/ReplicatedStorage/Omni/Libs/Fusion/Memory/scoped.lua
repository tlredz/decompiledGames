local parent = script.Parent.Parent
require(parent.Types)
local ExternalDebug = require(parent.ExternalDebug)
local merge = require(parent.Utility.merge)
local scopePool = require(parent.Memory.scopePool)

local function scoped(...)
	local self = setmetatable(scopePool.reuseAny() or {}, {
		__index = merge(false, {}, ...)
	})
	ExternalDebug.trackScope(self)
	return self
end

return scoped