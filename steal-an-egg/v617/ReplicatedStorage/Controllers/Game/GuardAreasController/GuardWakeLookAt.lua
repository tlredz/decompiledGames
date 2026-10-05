local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local t = require(ReplicatedStorage.Packages.t)
local Player = require(ReplicatedStorage.Shared.Player)
local WaitFor = require(ReplicatedStorage.Packages.WaitFor)
local GuardWakeLookAt = {}
GuardWakeLookAt.__index = GuardWakeLookAt
GuardWakeLookAt.__class = "GuardWakeLookAt"
local v = {
	Jungle = {
		AuthoredPitchAxis = vector.create(-0, -0, -1),
		BasePitch = 0.7853981633974483,
		MaxPitch = 1.3962634015954636,
		MinPitch = 0.17453292519943295,
		TargetPitchScale = -1
	}
}

function GuardWakeLookAt.new(folder)
	t.strict(t.instanceIsA("Model"))(folder)
	local object = setmetatable({}, GuardWakeLookAt)
	local v2, part = WaitFor.Descendant(folder, "Head"):await()
	local humanoidRootPart = folder:WaitForChild("HumanoidRootPart")
	local parent = folder.Parent
	assert(v2 and part ~= nil, (`{folder:GetFullName()} requires a Head descendant for wake look-at`))
	assert(part:IsA("BasePart"), (`{part:GetFullName()} must be a BasePart`))
	assert(humanoidRootPart:IsA("BasePart"), (`{humanoidRootPart:GetFullName()} must be a BasePart`))
	local v3

	if parent == nil then
		v3 = false
	else
		v3 = parent:IsA("Model")
	end

	assert(v3, (`{folder:GetFullName()} requires an area Model parent`))
	local headLookAtBoneName = folder:GetAttribute("HeadLookAtBoneName")
	local bone = nil
	local motor6D = nil

	if headLookAtBoneName == nil then
		local headLookAtMotorName = folder:GetAttribute("HeadLookAtMotorName")
		t.strict(t.optional(t.string))(headLookAtMotorName)
		local v4 = headLookAtMotorName or "Head"
		local v5
		v5, motor6D = WaitFor.Custom(function()
			for _, motor6D2 in ipairs(folder:GetDescendants()) do
				if motor6D2:IsA("Motor6D") and motor6D2.Name == v4 then
					return motor6D2
				end
			end

			return nil
		end):await()
		assert(v5 and motor6D ~= nil, (`{folder:GetFullName()} requires Motor6D "{v4}" for wake look-at`))
		assert(motor6D:IsA("Motor6D"), (`{motor6D:GetFullName()} must be a Motor6D`))
	else
		t.strict(t.string)(headLookAtBoneName)
		local v4
		v4, bone = WaitFor.Custom(function()
			for _, bone2 in ipairs(folder:GetDescendants()) do
				if bone2:IsA("Bone") and bone2.Name == headLookAtBoneName then
					return bone2
				end
			end

			return nil
		end):await()
		assert(
			v4 and bone ~= nil,
			(`{folder:GetFullName()} requires Bone "{headLookAtBoneName}" for HeadLookAtBoneName`)
		)
		assert(bone:IsA("Bone"), (`{bone:GetFullName()} must be a Bone`))
	end

	local worldCFrame

	if bone == nil then
		assert(motor6D ~= nil, (`{folder:GetFullName()} wake look-at requires a Motor6D or Bone`))
		local part0 = motor6D.Part0
		assert(part0 ~= nil, (`{motor6D:GetFullName()} requires Part0 for wake look-at`))
		worldCFrame = part0.CFrame * motor6D.C0
	else
		worldCFrame = bone.WorldCFrame
	end

	local areaLookOverride = v[parent.Name]
	local objectSpace = worldCFrame.Rotation:ToObjectSpace(humanoidRootPart.CFrame.Rotation)

	if areaLookOverride ~= nil then
		assert(bone ~= nil, (`{folder:GetFullName()} area look override requires a Bone`))
	end

	object._areaLookOverride = areaLookOverride
	object._appliedOffset = CFrame.identity
	object._bone = bone
	object._currentOffset = CFrame.identity
	object._guardModel = folder
	object._isWaking = false
	object._jointToFacingRotation = objectSpace
	object._motor = motor6D
	object._preAnimationConnection = nil
	object._preSimulationConnection = nil
	object._root = humanoidRootPart
	object._targetPitchReference = nil
	object._targetUserId = nil
	return object
end

function GuardWakeLookAt:_getJointTransform()
	local _bone = self._bone

	if _bone ~= nil then
		return _bone.Transform
	end

	local _motor = self._motor
	assert(_motor ~= nil, (`{self._guardModel:GetFullName()} wake look-at requires a Motor6D or Bone`))
	return _motor.Transform
end

function GuardWakeLookAt:_setJointTransform(transform: CFrame)
	local _bone = self._bone

	if _bone ~= nil then
		_bone.Transform = transform
		return
	end

	local _motor = self._motor
	assert(_motor ~= nil, (`{self._guardModel:GetFullName()} wake look-at requires a Motor6D or Bone`))
	_motor.Transform = transform
end

function GuardWakeLookAt:_getAnimationJointWorldCFrame()
	local _bone = self._bone

	if _bone ~= nil then
		return _bone.TransformedWorldCFrame * self._appliedOffset:Inverse()
	end

	local _motor = self._motor
	assert(_motor ~= nil, (`{self._guardModel:GetFullName()} wake look-at requires a Motor6D or Bone`))
	local part0 = _motor.Part0
	assert(part0 ~= nil, (`{_motor:GetFullName()} requires Part0 for wake look-at`))
	local v2 = _motor.Transform * self._appliedOffset:Inverse()
	return part0.CFrame * _motor.C0 * v2
end

function GuardWakeLookAt:_getAnimationJointTransform()
	return self:_getJointTransform() * self._appliedOffset:Inverse()
end

function GuardWakeLookAt:_getTargetOffset()
	if not self._isWaking then
		return CFrame.identity
	end

	local rootPart = Player.FindRootPart(Players.LocalPlayer)

	if rootPart == nil or (rootPart.Position - self._root.Position).Magnitude > 400 then
		return CFrame.identity
	end

	local _targetUserId = self._targetUserId

	if _targetUserId == nil then
		return CFrame.identity
	end

	local v2 = tonumber(_targetUserId)
	assert(v2 ~= nil, (`{self._guardModel:GetFullName()}.WakeTargetPlayer must be a user id`))
	local playerByUserId = Players:GetPlayerByUserId(v2)

	if playerByUserId == nil then
		return CFrame.identity
	end

	local head = Player.FindHead(playerByUserId)

	if head == nil then
		return CFrame.identity
	end

	local _getAnimationJointWorldCFrame = self:_getAnimationJointWorldCFrame()
	local cframe = CFrame.new(_getAnimationJointWorldCFrame.Position) * self._root.CFrame.Rotation
	local v3 = head.Position - cframe.Position

	if v3.Magnitude <= 0.001 then
		return CFrame.identity
	end

	local vectorToObjectSpace = cframe:VectorToObjectSpace(v3.Unit)
	local targetPitchReference = math.asin(vectorToObjectSpace.Y)
	local v5 = math.clamp(
		-math.atan2(vectorToObjectSpace.X, -vectorToObjectSpace.Z),
		-1.0471975511965976,
		1.0471975511965976
	)
	local _areaLookOverride = self._areaLookOverride

	if _areaLookOverride == nil then
		local v6 = math.clamp(targetPitchReference, -0.6108652381980153, 0.6108652381980153)
		local v7 = (cframe * CFrame.Angles(v6, v5, 0)).Rotation * self._jointToFacingRotation:Inverse()
		return _getAnimationJointWorldCFrame.Rotation:ToObjectSpace(v7)
	else
		local _targetPitchReference = self._targetPitchReference

		if _targetPitchReference == nil then
			self._targetPitchReference = targetPitchReference
			_targetPitchReference = targetPitchReference
		end

		local _getAnimationJointTransform = self:_getAnimationJointTransform()
		local v6 = _getAnimationJointWorldCFrame.Rotation * _getAnimationJointTransform.Rotation:Inverse()
		local v7 = math.clamp(
			_areaLookOverride.BasePitch + (targetPitchReference - _targetPitchReference) * _areaLookOverride.TargetPitchScale,
			_areaLookOverride.MinPitch,
			_areaLookOverride.MaxPitch
		)
		local cframe2 = CFrame.fromAxisAngle(_areaLookOverride.AuthoredPitchAxis, v7)
		local v8 = CFrame.fromAxisAngle(self._root.CFrame.UpVector, v5) * v6 * cframe2 * _getAnimationJointTransform.Rotation
		return _getAnimationJointWorldCFrame.Rotation:ToObjectSpace(v8)
	end
end

function GuardWakeLookAt:_applyOffset(appliedOffset: CFrame)
	self:_setJointTransform(self:_getJointTransform() * appliedOffset)
	self._appliedOffset = appliedOffset
end

function GuardWakeLookAt:_restoreAppliedOffset()
	self:_setJointTransform(self:_getJointTransform() * self._appliedOffset:Inverse())
	self._appliedOffset = CFrame.identity
end

function GuardWakeLookAt:_isOffsetAtRest()
	local orientation, v2, v3 = self._currentOffset:ToOrientation()
	return math.max(math.abs(orientation), math.abs(v2), (math.abs(v3))) <= 0.001
end

function GuardWakeLookAt:_step(p: number)
	local _getTargetOffset = self:_getTargetOffset()
	local v2 = 1 - math.exp(p * -3.5)
	self._currentOffset = self._currentOffset:Lerp(_getTargetOffset, v2)
	self:_applyOffset(self._currentOffset)

	if self._isWaking or not self:_isOffsetAtRest() then
		return false
	end

	self._currentOffset = CFrame.identity
	self:_restoreAppliedOffset()
	return true
end

function GuardWakeLookAt:_ensureAnimation()
	if self._preSimulationConnection ~= nil then
		return
	end

	assert(self._preAnimationConnection == nil, "wake look-at frame connections must share a lifecycle")
	self._preAnimationConnection = RunService.PreAnimation:Connect(function()
		self:_restoreAppliedOffset()
	end)
	self._preSimulationConnection = RunService.PreSimulation:Connect(function(dt: number)
		if self:_step(dt) then
			self:_disconnectAnimation()
		end
	end)
end

function GuardWakeLookAt:_disconnectAnimation()
	local _preAnimationConnection = self._preAnimationConnection

	if _preAnimationConnection ~= nil then
		self._preAnimationConnection = nil
		_preAnimationConnection:Disconnect()
	end

	local _preSimulationConnection = self._preSimulationConnection

	if _preSimulationConnection ~= nil then
		self._preSimulationConnection = nil
		_preSimulationConnection:Disconnect()
	end
end

function GuardWakeLookAt:SetWaking(isWaking: boolean, targetUserId: string?)
	t.strict(t.boolean)(isWaking)
	t.strict(t.optional(t.string))(targetUserId)

	if not isWaking or not self._isWaking or targetUserId ~= self._targetUserId then
		self._targetPitchReference = nil
	end

	self._isWaking = isWaking
	self._targetUserId = targetUserId

	if isWaking or not self:_isOffsetAtRest() then
		self:_ensureAnimation()
	end
end

function GuardWakeLookAt:Destroy()
	self._isWaking = false
	self._targetPitchReference = nil
	self._targetUserId = nil
	self._currentOffset = CFrame.identity
	self:_restoreAppliedOffset()
	self:_disconnectAnimation()
end

return GuardWakeLookAt