local parent = script.Parent.Parent
require(parent.Types)
local poisonScope = require(parent.Memory.poisonScope)
local ExternalDebug = require(parent.ExternalDebug)
local v = {}
local v2 = 0
local ScopePool = {}

function ScopePool.giveIfEmpty(items)
	if next(items) ~= nil then
		return items
	end

	ExternalDebug.untrackScope(items)
	poisonScope(items, "previously passed to the internal scope pool, which indicates a Fusion bug.")
	return nil
end

function ScopePool.clearAndGive(list)
	ExternalDebug.untrackScope(list)
	table.clear(list)
	poisonScope(list, "previously passed to the internal scope pool, which indicates a Fusion bug.")
end

function ScopePool.reuseAny()
	if v2 == 0 then
		return nil
	end

	local v3 = v[v2]
	v2 -= 1
	return v3
end

return ScopePool