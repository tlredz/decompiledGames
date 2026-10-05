local parent = script.Parent.Parent
require(parent.Types)
local External = require(parent.External)
local checkLifetime = require(parent.Memory.checkLifetime)
local depend = require(parent.Graph.depend)
local change = require(parent.Graph.change)
local evaluate = require(parent.Graph.evaluate)
local castToState = require(parent.State.castToState)
local peek = require(parent.State.peek)
local ExternalTime = require(parent.Animation.ExternalTime)
local Stopwatch = require(parent.Animation.Stopwatch)
local packType = require(parent.Animation.packType)
local unpackType = require(parent.Animation.unpackType)
local springCoefficients = require(parent.Animation.springCoefficients)
local nicknames = require(parent.Utility.nicknames)
local v = {
	type = "State",
	kind = "Spring",
	timeliness = "eager"
}
local frozen = table.freeze({
	__index = v
})

local function Spring(scope, goal, value, value2)
	local now = os.clock()

	if typeof(scope) ~= "table" or castToState(scope) ~= nil then
		External.logError("scopeMissing", nil, "Springs", "myScope:Spring(goalState, speed, damping)")
	end

	local v2 = castToState(goal)
	local stopwatch

	if v2 ~= nil then
		stopwatch = Stopwatch(scope, ExternalTime(scope))
		stopwatch:unpause()
	end

	local speed = value or 10
	local damping = value2 or 1
	local object = setmetatable({
		createdAt = now,
		dependencySet = {},
		dependentSet = {},
		lastChange = nil,
		scope = scope,
		validity = "invalid",
		_activeDamping = -1,
		_activeGoal = nil,
		_activeLatestP = {},
		_activeLatestV = {},
		_activeNumSprings = 0,
		_activeSpeed = -1,
		_activeStartP = {},
		_activeStartV = {},
		_activeTargetP = {},
		_activeType = "",
		_damping = damping,
		_EXTREMELY_DANGEROUS_usedAsValue = peek(goal),
		_goal = goal,
		_speed = speed,
		_stopwatch = stopwatch
	}, frozen)

	local function fn()
		object.scope = nil

		for k in pairs(object.dependencySet) do
			k.dependentSet[object] = nil
		end
	end

	object.oldestTask = fn
	nicknames[object.oldestTask] = "Spring"
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

	local v6 = castToState(speed)

	if v6 ~= nil then
		checkLifetime.bOutlivesA(
			scope,
			object.oldestTask,
			v6.scope,
			v6.oldestTask,
			checkLifetime.formatters.parameter,
			"speed"
		)
	end

	local v7 = castToState(damping)

	if v7 ~= nil then
		checkLifetime.bOutlivesA(
			scope,
			object.oldestTask,
			v7.scope,
			v7.oldestTask,
			checkLifetime.formatters.parameter,
			"damping"
		)
	end

	evaluate(object, true)
	return object
end

function v:addVelocity(p)
	evaluate(self, false)
	local typeName = typeof(p)

	if typeName ~= self._activeType then
		External.logError("springTypeMismatch", nil, typeName, self._activeType)
	end

	local activeStartV = unpackType(p, typeName)

	for k, v3 in self._activeLatestV do
		activeStartV[k] += v3
	end

	self._activeStartP = table.clone(self._activeLatestP)
	self._activeStartV = activeStartV
	self._stopwatch:zero()
	self._stopwatch:unpause()
	change(self)
end

function v.get(_)
	return External.logError("stateGetWasRemoved")
end

function v:setPosition(p)
	evaluate(self, false)
	local typeName = typeof(p)

	if typeName ~= self._activeType then
		External.logError("springTypeMismatch", nil, typeName, self._activeType)
	end

	self._activeStartP = unpackType(p, typeName)
	self._activeStartV = table.clone(self._activeLatestV)
	self._stopwatch:zero()
	self._stopwatch:unpause()
	change(self)
end

function v:setVelocity(p)
	evaluate(self, false)
	local typeName = typeof(p)

	if typeName ~= self._activeType then
		External.logError("springTypeMismatch", nil, typeName, self._activeType)
	end

	self._activeStartP = table.clone(self._activeLatestP)
	self._activeStartV = unpackType(p, typeName)
	self._stopwatch:zero()
	self._stopwatch:unpause()
	change(self)
end

function v:_evaluate()
	local v2 = castToState(self._goal)

	if v2 == nil then
		self._EXTREMELY_DANGEROUS_usedAsValue = self._goal
		return false
	end

	local activeGoal = peek(v2)

	if activeGoal ~= activeGoal then
		External.logWarn("springNanGoal")
		return false
	end

	local typeName = typeof(activeGoal)
	local v4 = typeName ~= self._activeType
	local _stopwatch = self._stopwatch
	local current_stopwatch = peek(_stopwatch)
	depend(self, _stopwatch)
	local _EXTREMELY_DANGEROUS_usedAsValue = self._EXTREMELY_DANGEROUS_usedAsValue
	local v5

	if v4 then
		v5 = activeGoal
	elseif current_stopwatch <= 0 then
		v5 = _EXTREMELY_DANGEROUS_usedAsValue
	else
		local v6, v7, v8, v9 = springCoefficients(current_stopwatch, self._activeDamping, self._activeSpeed)
		local v10 = false

		for i = 1, self._activeNumSprings do
			local v11 = self._activeStartP[i]
			local v12 = self._activeTargetP[i]
			local v13 = self._activeStartV[i]
			local v14 = v11 - v12
			local v15 = v14 * v6 + v13 * v7
			local v16 = v14 * v8 + v13 * v9

			if v15 ~= v15 or v16 ~= v16 then
				External.logWarn("springNanMotion")
				v15 = 0
				v16 = 0
			end

			v10 = math.abs(v15) > 0.00001 or math.abs(v16) > 0.00001 or v10
			local v17 = v15 + v12
			self._activeLatestP[i] = v17
			self._activeLatestV[i] = v16
		end

		if not v10 then
			for i = 1, self._activeNumSprings do
				self._activeLatestP[i] = self._activeTargetP[i]
			end
		end

		v5 = packType(self._activeLatestP, self._activeType)
	end

	local _speed = peek(self._speed)
	local _damping = peek(self._damping)

	if v4 or activeGoal ~= self._activeGoal or _speed ~= self._activeSpeed or _damping ~= self._activeDamping then
		self._activeTargetP = unpackType(activeGoal, typeName)
		self._activeNumSprings = #self._activeTargetP

		if v4 then
			self._activeStartP = table.clone(self._activeTargetP)
			self._activeLatestP = table.clone(self._activeTargetP)
			self._activeStartV = table.create(self._activeNumSprings, 0)
			self._activeLatestV = table.create(self._activeNumSprings, 0)
		else
			self._activeStartP = table.clone(self._activeLatestP)
			self._activeStartV = table.clone(self._activeLatestV)
		end

		self._activeType = typeName
		self._activeGoal = activeGoal
		self._activeDamping = _damping
		self._activeSpeed = _speed
		_stopwatch:zero()
		_stopwatch:unpause()
	end

	self._EXTREMELY_DANGEROUS_usedAsValue = v5
	return _EXTREMELY_DANGEROUS_usedAsValue ~= v5
end

table.freeze(v)
return Spring