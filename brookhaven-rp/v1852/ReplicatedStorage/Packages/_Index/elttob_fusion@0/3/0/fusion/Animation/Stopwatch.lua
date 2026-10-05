local parent = script.Parent.Parent
require(parent.Types)
local checkLifetime = require(parent.Memory.checkLifetime)
local depend = require(parent.Graph.depend)
local change = require(parent.Graph.change)
local peek = require(parent.State.peek)
local nicknames = require(parent.Utility.nicknames)
local v = {
	type = "State",
	kind = "Stopwatch",
	timeliness = "lazy"
}
local frozen = table.freeze({
	__index = v
})

local function Stopwatch(scope, timer)
	local object = setmetatable({
		awake = true,
		createdAt = os.clock(),
		dependencySet = {},
		dependentSet = {},
		lastChange = nil,
		scope = scope,
		validity = "invalid",
		_EXTREMELY_DANGEROUS_usedAsValue = 0,
		_measureTimeSince = 0,
		_playing = false,
		_timer = timer
	}, frozen)

	local function fn()
		object.scope = nil
	end

	object.oldestTask = fn
	nicknames[object.oldestTask] = "Stopwatch"
	table.insert(scope, fn)
	checkLifetime.bOutlivesA(
		scope,
		object.oldestTask,
		timer.scope,
		timer.oldestTask,
		checkLifetime.formatters.parameter,
		"timer"
	)
	depend(object, timer)
	return object
end

function v:zero()
	local _timer = peek(self._timer)

	if _timer ~= self._measureTimeSince then
		self._measureTimeSince = _timer
		self._EXTREMELY_DANGEROUS_usedAsValue = 0
		change(self)
	end
end

function v:pause()
	if self._playing == true then
		self._playing = false
		change(self)
	end
end

function v:unpause()
	if self._playing == false then
		self._playing = true
		self._measureTimeSince = peek(self._timer) - self._EXTREMELY_DANGEROUS_usedAsValue
		change(self)
	end
end

function v:_evaluate()
	if not self._playing then
		return false
	end

	depend(self, self._timer)
	local _timer = peek(self._timer)
	local _EXTREMELY_DANGEROUS_usedAsValue = self._EXTREMELY_DANGEROUS_usedAsValue
	local v2 = _timer - self._measureTimeSince
	self._EXTREMELY_DANGEROUS_usedAsValue = v2
	return _EXTREMELY_DANGEROUS_usedAsValue ~= v2
end

table.freeze(v)
return Stopwatch