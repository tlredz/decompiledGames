local parent = script.Parent.Parent
require(parent.Types)
local External = require(parent.External)
local checkLifetime = require(parent.Memory.checkLifetime)
local depend = require(parent.Graph.depend)
local evaluate = require(parent.Graph.evaluate)
local castToState = require(parent.State.castToState)
local peek = require(parent.State.peek)
local ExternalTime = require(parent.Animation.ExternalTime)
local Stopwatch = require(parent.Animation.Stopwatch)
local lerpType = require(parent.Animation.lerpType)
local getTweenRatio = require(parent.Animation.getTweenRatio)
local getTweenDuration = require(parent.Animation.getTweenDuration)
local nicknames = require(parent.Utility.nicknames)
local v = {
	type = "State",
	kind = "Tween",
	timeliness = "eager"
}
local frozen = table.freeze({
	__index = v
})

local function Tween(scope, goal, p2)
	local now = os.clock()

	if castToState(scope) then
		External.logError("scopeMissing", nil, "Tweens", "myScope:Tween(goalState, tweenInfo)")
	end

	local v2 = castToState(goal)
	local stopwatch

	if v2 ~= nil then
		stopwatch = Stopwatch(scope, ExternalTime(scope))
	end

	local object = setmetatable({
		createdAt = now,
		dependencySet = {},
		dependentSet = {},
		lastChange = nil,
		scope = scope,
		validity = "invalid",
		_activeDuration = nil,
		_activeElapsed = nil,
		_activeFrom = nil,
		_activeTo = nil,
		_activeTweenInfo = nil,
		_EXTREMELY_DANGEROUS_usedAsValue = peek(goal),
		_goal = goal,
		_stopwatch = stopwatch,
		_tweenInfo = p2 or TweenInfo.new()
	}, frozen)

	local function fn()
		object.scope = nil

		for k in pairs(object.dependencySet) do
			k.dependentSet[object] = nil
		end
	end

	object.oldestTask = fn
	nicknames[object.oldestTask] = "Tween"
	table.insert(scope, fn)

	if v2 ~= nil then
		checkLifetime.bOutlivesA(
			scope,
			object.oldestTask,
			v2.scope,
			v2.oldestTask,
			checkLifetime.formatters.animationGoal
		)
	end

	local v4 = castToState(p2)

	if v4 ~= nil then
		checkLifetime.bOutlivesA(
			scope,
			object.oldestTask,
			v4.scope,
			v4.oldestTask,
			checkLifetime.formatters.parameter,
			"tween info"
		)
	end

	evaluate(object, true)
	return object
end

function v.get(_)
	return External.logError("stateGetWasRemoved")
end

function v:_evaluate()
	local v2 = castToState(self._goal)

	if v2 == nil then
		self._EXTREMELY_DANGEROUS_usedAsValue = self._goal
		return false
	end

	depend(self, v2)
	local activeTo = peek(v2)

	if activeTo ~= activeTo then
		External.logWarn("tweenNanGoal")
		return false
	end

	local _stopwatch = self._stopwatch
	local _tweenInfo = peek(self._tweenInfo)

	if self._activeTo ~= activeTo or self._activeElapsed < self._activeDuration and self._activeTweenInfo ~= _tweenInfo then
		self._activeDuration = getTweenDuration(_tweenInfo)
		self._activeFrom = self._EXTREMELY_DANGEROUS_usedAsValue
		self._activeTo = activeTo
		self._activeTweenInfo = _tweenInfo
		_stopwatch:zero()
		_stopwatch:unpause()
	end

	depend(self, _stopwatch)
	self._activeElapsed = peek(_stopwatch)

	if self._activeFrom == self._activeTo or self._activeElapsed >= self._activeDuration or typeof(self._activeTo) ~= typeof(self._activeFrom) then
		self._activeFrom = self._activeTo
		self._activeElapsed = self._activeDuration
		_stopwatch:pause()
	end

	local tweenRatio = getTweenRatio(_tweenInfo, self._activeElapsed)
	local _EXTREMELY_DANGEROUS_usedAsValue = self._EXTREMELY_DANGEROUS_usedAsValue
	local _activeTo = lerpType(self._activeFrom, self._activeTo, tweenRatio)

	if _activeTo ~= _activeTo then
		External.logWarn("tweenNanMotion")
		_activeTo = self._activeTo
	end

	self._EXTREMELY_DANGEROUS_usedAsValue = _activeTo
	return _EXTREMELY_DANGEROUS_usedAsValue ~= _activeTo
end

table.freeze(v)
return Tween