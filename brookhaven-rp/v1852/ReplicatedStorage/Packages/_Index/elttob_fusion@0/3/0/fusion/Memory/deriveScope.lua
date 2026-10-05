local parent = script.Parent.Parent
require(parent.Types)
local ExternalDebug = require(parent.ExternalDebug)
local deriveScopeImpl = require(parent.Memory.deriveScopeImpl)

local function deriveScope(...)
	local v = deriveScopeImpl(...)
	ExternalDebug.trackScope(v)
	return v
end

return deriveScope