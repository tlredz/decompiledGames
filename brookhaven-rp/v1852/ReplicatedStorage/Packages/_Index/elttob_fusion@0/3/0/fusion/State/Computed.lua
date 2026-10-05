local parent = script.Parent.Parent
require(parent.Types)
local External = require(parent.External)
local parseError = require(parent.Logging.parseError)
local isSimilar = require(parent.Utility.isSimilar)
local never = require(parent.Utility.never)
local depend = require(parent.Graph.depend)
local castToState = require(parent.State.castToState)
local peek = require(parent.State.peek)
local doCleanup = require(parent.Memory.doCleanup)
local deriveScope = require(parent.Memory.deriveScope)
local checkLifetime = require(parent.Memory.checkLifetime)
local scopePool = require(parent.Memory.scopePool)
local nicknames = require(parent.Utility.nicknames)
local v = {
	type = "State",
	kind = "Computed",
	timeliness = "lazy"
}
local frozen = table.freeze({
	__index = v
})

local function Computed(scope, processor, p)
	local now = os.clock()

	if typeof(scope) == "function" then
		External.logError("scopeMissing", nil, "Computeds", "myScope:Computed(function(use, scope) ... end)")
	elseif p ~= nil then
		External.logWarn("destructorRedundant", "Computed")
	end

	local object = setmetatable({
		createdAt = now,
		dependencySet = {},
		dependentSet = {},
		lastChange = nil,
		scope = scope,
		validity = "invalid",
		_EXTREMELY_DANGEROUS_usedAsValue = nil,
		_innerScope = nil,
		_processor = processor
	}, frozen)

	local function fn()
		object.scope = nil

		for k in pairs(object.dependencySet) do
			k.dependentSet[object] = nil
		end

		if object._innerScope ~= nil then
			doCleanup(object._innerScope)
		end
	end

	object.oldestTask = fn
	nicknames[object.oldestTask] = "Computed"
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

	local scope = self.scope
	local v2 = deriveScope(scope)

	local function use(p)
		local v3 = castToState(p)

		if v3 ~= nil then
			checkLifetime.bOutlivesA(
				scope,
				self.oldestTask,
				v3.scope,
				v3.oldestTask,
				checkLifetime.formatters.useFunction
			)
			depend(self, v3)
		end

		return peek(p)
	end

	local v3, v4 = xpcall(self._processor, parseError, use, v2)
	local innerScope = scopePool.giveIfEmpty(v2)

	if v3 then
		local similar = isSimilar(self._EXTREMELY_DANGEROUS_usedAsValue, v4)

		if self._innerScope ~= nil then
			doCleanup(self._innerScope)
		end

		self._innerScope = innerScope
		self._EXTREMELY_DANGEROUS_usedAsValue = v4
		return not similar
	else
		if innerScope ~= nil then
			doCleanup(innerScope)
		end

		External.logErrorNonFatal("callbackError", v4)
		return false
	end
end

table.freeze(v)
return Computed