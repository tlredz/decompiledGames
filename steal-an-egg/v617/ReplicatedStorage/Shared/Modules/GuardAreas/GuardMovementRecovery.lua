local ReplicatedStorage = game:GetService("ReplicatedStorage")
local guardRecovery = require(ReplicatedStorage.Shared.Flags.GameplayBalance).GuardRecovery
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Log = require(ReplicatedStorage2.Packages.Log)
local t = require(ReplicatedStorage2.Packages.t)
local v = Log.new()
local GuardMovementRecovery = {}
GuardMovementRecovery.__index = GuardMovementRecovery
GuardMovementRecovery.__class = "GuardMovementRecovery"

function GuardMovementRecovery.new(root, ground)
	t.strict(t.instanceIsA("BasePart"))(root)
	t.strict(t.instanceIsA("BasePart"))(ground)
	local self = setmetatable({}, GuardMovementRecovery)
	self._ground = ground
	self._lastProgressPosition = nil
	self._lastProgressTime = 0
	self._returnHomeStartedAt = nil
	self._root = root
	return self
end

function GuardMovementRecovery:_getHorizontalDistance(vector: Vector3)
	local v2 = self._root.Position - vector
	return Vector3.new(v2.X, 0, v2.Z).Magnitude
end

function GuardMovementRecovery:Reset()
	self._lastProgressPosition = nil
	self._lastProgressTime = 0
	self._returnHomeStartedAt = nil
end

function GuardMovementRecovery:ShouldRecoverFromFall()
	if self._root.Position.Y >= self._ground.Position.Y - guardRecovery.FALL_RECOVERY_DEPTH then
		return false
	end

	v:AtWarning():Log((`Guard fell below the world and requires recovery: {self._root:GetFullName()}`))
	return true
end

function GuardMovementRecovery:Step(p: number, flag: boolean, flag2: boolean)
	t.strict(t.number)(p)
	t.strict(t.boolean)(flag)
	t.strict(t.boolean)(flag2)

	if flag2 then
		local _returnHomeStartedAt = self._returnHomeStartedAt

		if _returnHomeStartedAt == nil then
			self._returnHomeStartedAt = p
		elseif p - _returnHomeStartedAt >= guardRecovery.RETURN_HOME_TIMEOUT then
			v:AtWarning():Log((`Guard return-home timeout triggered for {self._root:GetFullName()}`))
			self:Reset()
			return true
		end
	else
		self._returnHomeStartedAt = nil
	end

	if flag then
		local _lastProgressPosition = self._lastProgressPosition

		if _lastProgressPosition == nil then
			self._lastProgressPosition = self._root.Position
			self._lastProgressTime = p
			return false
		elseif self:_getHorizontalDistance(_lastProgressPosition) >= guardRecovery.MINIMUM_HORIZONTAL_PROGRESS then
			self._lastProgressPosition = self._root.Position
			self._lastProgressTime = p
			return false
		else
			if p - self._lastProgressTime < guardRecovery.STUCK_TIMEOUT then
				return false
			end

			v:AtWarning():Log((`Guard stuck recovery triggered for {self._root:GetFullName()}`))
			self:Reset()
			return true
		end
	else
		self._lastProgressPosition = nil
		self._lastProgressTime = 0
		return false
	end
end

return GuardMovementRecovery