local parent = script.Parent.Parent
require(parent.Types)
local External = require(parent.External)
local depend = require(parent.Graph.depend)
local peek = require(parent.State.peek)
local castToState = require(parent.State.castToState)
require(parent.State.For.ForTypes)
local never = require(parent.Utility.never)
local nicknames = require(parent.Utility.nicknames)
local Disassembly = require(parent.State.For.Disassembly)
local v = {
	type = "State",
	kind = "For",
	timeliness = "lazy"
}
local frozen = table.freeze({
	__index = v
})

local function For(scope, p, callback)
	local object = setmetatable({
		createdAt = os.clock(),
		dependencySet = {},
		dependentSet = {},
		scope = scope,
		validity = "invalid",
		_EXTREMELY_DANGEROUS_usedAsValue = {},
		_disassembly = Disassembly(scope, p, callback)
	}, frozen)

	local function fn()
		object.scope = nil

		for k in pairs(object.dependencySet) do
			k.dependentSet[object] = nil
		end
	end

	object.oldestTask = fn
	nicknames[object.oldestTask] = "For"
	table.insert(scope, fn)
	return object
end

function v.get(_)
	External.logError("stateGetWasRemoved")
	return never()
end

function v:_evaluate()
	if self.scope == nil then
		return false
	end

	local _ = self.scope
	depend(self, self._disassembly)
	table.clear(self._EXTREMELY_DANGEROUS_usedAsValue)
	self._disassembly:populate(function(p)
		local v2 = castToState(p)

		if v2 ~= nil then
			depend(self, v2)
		end

		return peek(p)
	end, self._EXTREMELY_DANGEROUS_usedAsValue)
	return true
end

table.freeze(v)
return For