local parent = script.Parent.Parent
require(parent.Types)
local External = require(parent.External)
local checkLifetime = require(parent.Memory.checkLifetime)
local castToGraph = require(parent.Graph.castToGraph)
local depend = require(parent.Graph.depend)
local evaluate = require(parent.Graph.evaluate)
local nicknames = require(parent.Utility.nicknames)
local v = {
	type = "Observer",
	timeliness = "eager",
	dependentSet = table.freeze({})
}
local frozen = table.freeze({
	__index = v
})

local function Observer(scope, p)
	local now = os.clock()

	if p == nil then
		External.logError("scopeMissing", nil, "Observers", "myScope:Observer(watching)")
	end

	local object = setmetatable({
		scope = scope,
		createdAt = now,
		dependencySet = {},
		lastChange = nil,
		validity = "invalid",
		_watchingGraph = castToGraph(p),
		_changeListeners = {}
	}, frozen)

	local function fn()
		object.scope = nil

		for k in pairs(object.dependencySet) do
			k.dependentSet[object] = nil
		end
	end

	object.oldestTask = fn
	nicknames[object.oldestTask] = "Observer"
	table.insert(scope, fn)

	if object._watchingGraph ~= nil then
		checkLifetime.bOutlivesA(
			scope,
			object.oldestTask,
			object._watchingGraph.scope,
			object._watchingGraph.oldestTask,
			checkLifetime.formatters.observer
		)
	end

	evaluate(object, true)
	return object
end

function v:onBind(callback)
	External.doTaskImmediate(callback)
	return self:onChange(callback)
end

function v:onChange(callback)
	local frozen2 = table.freeze({})
	self._changeListeners[frozen2] = callback
	return function()
		self._changeListeners[frozen2] = nil
	end
end

function v:_evaluate()
	if self._watchingGraph ~= nil then
		depend(self, self._watchingGraph)
	end

	for _, _changeListener in self._changeListeners do
		External.doTaskImmediate(_changeListener)
	end

	return true
end

table.freeze(v)
return Observer