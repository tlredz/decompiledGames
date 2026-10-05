local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Maid = require(game.ReplicatedStorage.Util.Maid)
local AttributeCounter = require(game.ReplicatedStorage.Util.AttributeCounter)
local Animations = require(script.Animations)
local CameraTarget = require(script.CameraTarget)
require(script.Types)
local Global = require(game.ReplicatedStorage.Global)
local CameraController = {}
CameraController.__index = CameraController
local v = Enum.RenderPriority.Camera.Value + 1
local v2 = {}
local count = 0
local fn

-- equivalent calls inferred from this helper; original call sites unknown
local function clampWeight(value: number)
	return (math.clamp(value, 0, 1))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getControllerBlendCFrame(controller)
	return controller._fadeOutCFrame or controller._currentCFrame
end

local function applyFieldOfView(state)
	local flag = false

	for _, controller in state.Controllers do
		if not (controller._currentFieldOfView ~= nil and controller._weight > 0.0001) then
			continue
		end

		flag = true
		break
	end

	local camera = state.Camera

	if flag then
		if not state.IsFieldOfViewControlled then
			state.PreviousFieldOfView = camera.FieldOfView
			state.IsFieldOfViewControlled = true
		end

		local previousFieldOfView = state.PreviousFieldOfView

		for _, controller in state.Controllers do
			local _currentFieldOfView = controller._currentFieldOfView

			if not (_currentFieldOfView ~= nil and controller._weight > 0.0001) then
				continue
			end

			local _weight = controller._weight

			if _weight >= 0.9999 then
				previousFieldOfView = _currentFieldOfView
			else
				previousFieldOfView += (_currentFieldOfView - previousFieldOfView) * _weight
			end
		end

		camera.FieldOfView = previousFieldOfView
	else
		if not state.IsFieldOfViewControlled then
			state.PreviousFieldOfView = camera.FieldOfView
			return
		end

		camera.FieldOfView = state.PreviousFieldOfView
		state.IsFieldOfViewControlled = false
	end
end

local function syncCameraOwnership(state)
	local camera = state.Camera
	local flag = false

	for _, controller in state.Controllers do
		if controller._allowsPlayerRotation or not (controller._weight > 0.0001) then
			continue
		end

		flag = true
		break
	end

	if flag then
		if camera.CameraType ~= Enum.CameraType.Scriptable then
			state.PreviousCameraType = camera.CameraType
		end

		if not state.IsScriptable or camera.CameraType ~= Enum.CameraType.Scriptable then
			camera.CameraType = Enum.CameraType.Scriptable
			state.IsScriptable = true
		end
	elseif state.IsScriptable then
		camera.CameraType = state.PreviousCameraType
		state.IsScriptable = false
	elseif camera.CameraType ~= Enum.CameraType.Scriptable then
		state.PreviousCameraType = camera.CameraType
	end
end

local function getStackState(_camera)
	local v3 = v2[_camera]

	if v3 then
		return v3
	end

	count += 1
	local formatted = `CameraControllerStack_{count}`
	local v4 = {
		Camera = _camera,
		Controllers = {},
		RenderStepName = formatted,
		PreviousCameraType = _camera.CameraType,
		PreviousFieldOfView = _camera.FieldOfView,
		IsFieldOfViewControlled = false,
		IsScriptable = false
	}
	RunService:BindToRenderStep(formatted, v, function(p: number)
		fn(v4, p)
	end)
	v2[_camera] = v4
	return v4
end

local function updateWeight(controller, p: number)
	if not controller._blending then
		return false
	end

	local _blendTime = controller._blendTime

	if _blendTime <= 0 then
		controller._weight = controller._targetWeight
	else
		controller._blendElapsed += p
		local v3 = clampWeight(controller._blendElapsed / _blendTime) -- equivalent call inferred; original call site unknown
		controller._weight = controller._blendStartWeight + (controller._targetWeight - controller._blendStartWeight) * v3
	end

	if _blendTime <= controller._blendElapsed then
		controller._weight = controller._targetWeight
		controller._blending = false
		return controller._destroyOnBlendComplete and controller._weight <= 0.0001
	else
		return false
	end
end

local function startWeightBlend(instance, value: number, value2: number?, destroyOnBlendComplete: boolean)
	if instance._destroyed then
		return
	end

	local v3 = clampWeight(value) -- equivalent call inferred; original call site unknown
	local blendTime = math.max(value2 or 0, 0)

	if not (destroyOnBlendComplete and v3 <= 0.0001) then
		instance._fadeOutCFrame = nil
	end

	instance._targetWeight = v3
	instance._blendStartWeight = instance._weight
	instance._blendElapsed = 0
	instance._blendTime = blendTime
	instance._destroyOnBlendComplete = destroyOnBlendComplete

	if blendTime <= 0 then
		instance._weight = v3
		instance._blending = false

		if destroyOnBlendComplete and v3 <= 0.0001 then
			instance:Destroy()
		end
	else
		instance._blending = true
	end

	local v5 = v2[instance._camera]

	if v5 then
		syncCameraOwnership(v5)
	end
end

fn = function(p, p2: number)
	local controllers = p.Controllers
	local camera = p.Camera
	local cFrame = camera.CFrame
	local controllers2 = nil

	for _, controller in controllers do
		local v3 = updateWeight(controller, p2)
		local _cameraTarget = controller._cameraTarget

		if _cameraTarget then
			_cameraTarget:Update(p2)
		end

		controller.Animations:Update(p2)
		local _weight = controller._weight

		if _weight > 0.0001 then
			local controllerBlendCFrame = getControllerBlendCFrame(controller) -- equivalent call inferred; original call site unknown

			if _weight >= 0.9999 then
				cFrame = controllerBlendCFrame
			else
				cFrame = cFrame:Lerp(controllerBlendCFrame, _weight)
			end
		end

		if not v3 then
			continue
		end

		controllers2 = controllers2 or {}
		table.insert(controllers2, controller)
	end

	syncCameraOwnership(p)
	camera.CFrame = cFrame
	applyFieldOfView(p)

	if controllers2 then
		for _, v3 in controllers2 do
			v3:Destroy()
		end
	end
end

function CameraController.hasActiveControllers(p)
	local v3 = v2[p]
	return v3 ~= nil and #v3.Controllers > 0
end

function CameraController.bindRespawnRecovery()
	local RespawnRecovery = require(script.RespawnRecovery)
	RespawnRecovery.bind(CameraController)
end

function CameraController.new(p, value: number?, value2: number?)
	local camera = p or workspace.CurrentCamera
	local targetWeight = clampWeight(value or 1) -- equivalent call inferred; original call site unknown
	local blendTime = math.max(value2 or 0, 0)
	local localPlayer = Players.LocalPlayer
	local HttpService = game:GetService("HttpService")
	local v6 = {
		_uid = HttpService:GenerateGUID(false):sub(1, 5),
		_maid = Maid.new(),
		_camera = camera,
		_weight = blendTime > 0 and 0 or targetWeight,
		_targetWeight = targetWeight,
		_blendStartWeight = 0,
		_blendElapsed = 0,
		_blendTime = blendTime,
		_blending = blendTime > 0 and targetWeight > 0,
		_destroyOnBlendComplete = false,
		_fadeOutCFrame = nil,
		_currentFieldOfView = nil,
		_areAnimationsInstant = Global.REDUCE_MOTION,
		_allowsPlayerRotation = false,
		_npcInteractionLock = nil,
		_destroyed = false
	}
	local self = setmetatable(v6, CameraController)
	self._currentCFrame = self._camera.CFrame
	self.Animations = Animations.new(self)
	self._maid:GiveTask(self.Animations)
	local stackState = getStackState(self._camera)
	self._previousCameraType = stackState.PreviousCameraType
	table.insert(stackState.Controllers, self)
	syncCameraOwnership(stackState)

	if not localPlayer then
		return self
	end

	local destroyable = AttributeCounter.destroyable(localPlayer, "NPC_INTERACTION_LOCK")
	self._npcInteractionLock = destroyable
	self._maid:GiveTask(destroyable)
	local CharacterLifetime = require(script.CharacterLifetime)
	CharacterLifetime.bind(self, localPlayer)
	return self
end

function CameraController:GetCFrame()
	return self._currentCFrame
end

function CameraController:GetWeight()
	return self._weight
end

function CameraController:SetWeight(value: number, value2: number?)
	if self._destroyed then
		return
	end

	local v3 = clampWeight(value) -- equivalent call inferred; original call site unknown
	local blendTime = math.max(value2 or 0, 0)
	self._fadeOutCFrame = nil
	self._targetWeight = v3
	self._blendStartWeight = self._weight
	self._blendElapsed = 0
	self._blendTime = blendTime
	self._destroyOnBlendComplete = false

	if blendTime <= 0 then
		self._weight = v3
		self._blending = false
	else
		self._blending = true
	end

	local v5 = v2[self._camera]

	if v5 then
		syncCameraOwnership(v5)
	end
end

function CameraController:AdjustWeight(p: number, p2: number?)
	self:SetWeight(p, p2)
end

function CameraController:GetAllowsPlayerRotation()
	return self._allowsPlayerRotation
end

function CameraController:SetAllowsPlayerRotation(allowsPlayerRotation: boolean)
	self._allowsPlayerRotation = allowsPlayerRotation
	local v3 = v2[self._camera]

	if v3 then
		syncCameraOwnership(v3)
	end
end

function CameraController:SetAreAnimationsInstant(areAnimationsInstant: boolean)
	self._areAnimationsInstant = areAnimationsInstant

	if areAnimationsInstant then
		self.Animations:SkipToGoal()

		if self._cameraTarget then
			self._cameraTarget:SkipToGoal()
		end

		if self._blending then
			local _targetWeight = self._targetWeight
			local _destroyOnBlendComplete = self._destroyOnBlendComplete

			if self._destroyed then
				return
			end

			local v3 = clampWeight(_targetWeight) -- equivalent call inferred; original call site unknown

			if not (_destroyOnBlendComplete and v3 <= 0.0001) then
				self._fadeOutCFrame = nil
			end

			self._targetWeight = v3
			self._blendStartWeight = self._weight
			self._blendElapsed = 0
			self._blendTime = 0
			self._destroyOnBlendComplete = _destroyOnBlendComplete
			self._weight = v3
			self._blending = false

			if _destroyOnBlendComplete and v3 <= 0.0001 then
				self:Destroy()
			end

			local v4 = v2[self._camera]

			if v4 then
				syncCameraOwnership(v4)
			end
		end
	end
end

function CameraController:FadeOut(p: number?)
	self._fadeOutCFrame = self._camera.CFrame
	self.Animations:_stopFieldOfView()
	self:SetAllowsPlayerRotation(true)
	local v3 = self._areAnimationsInstant and 0 or p

	if self._destroyed then
		return
	end

	local v4 = 0
	local blendTime = math.max(v3 or 0, 0)

	if v4 > 0.0001 then
		self._fadeOutCFrame = nil
	end

	self._targetWeight = v4
	self._blendStartWeight = self._weight
	self._blendElapsed = 0
	self._blendTime = blendTime
	self._destroyOnBlendComplete = true

	if blendTime <= 0 then
		self._weight = v4
		self._blending = false

		if v4 <= 0.0001 then
			self:Destroy()
		end
	else
		self._blending = true
	end

	local v6 = v2[self._camera]

	if v6 then
		syncCameraOwnership(v6)
	end
end

function CameraController:TeleportTo(cFrame: CFrame)
	self:SetCFrame(cFrame)
	self._fadeOutCFrame = nil
	self._camera.CFrame = cFrame
end

function CameraController:TeleportBack(cframe: CFrame)
	self:TeleportTo(cframe)
	self.Animations:_stopFieldOfView()
	self:SetAllowsPlayerRotation(true)

	if self._destroyed then
		return
	end

	local v3 = 0

	if v3 > 0.0001 then
		self._fadeOutCFrame = nil
	end

	self._targetWeight = v3
	self._blendStartWeight = self._weight
	self._blendElapsed = 0
	self._blendTime = 0
	self._destroyOnBlendComplete = true
	self._weight = v3
	self._blending = false

	if v3 <= 0.0001 then
		self:Destroy()
	end

	local v4 = v2[self._camera]

	if v4 then
		syncCameraOwnership(v4)
	end
end

function CameraController:SetCFrame(currentCFrame: CFrame)
	self:ClearCameraTarget()
	self.Animations:Stop()
	self._currentCFrame = currentCFrame
end

function CameraController:SetCameraTarget(p)
	self.Animations:Stop()

	if self._cameraTarget then
		self._cameraTarget:Destroy()
	end

	local cameraTarget = CameraTarget.new(self, p)
	self._cameraTarget = cameraTarget
	return cameraTarget
end

function CameraController:ClearCameraTarget()
	if self._cameraTarget then
		self._cameraTarget:Destroy()
	end
end

function CameraController:Destroy()
	if self._destroyed then
		return
	end

	self._destroyed = true
	self:ClearCameraTarget()
	local v3 = v2[self._camera]
	local index = v3 and table.find(v3.Controllers, self)

	if index then
		table.remove(v3.Controllers, index)
	end

	if v3 and #v3.Controllers == 0 then
		RunService:UnbindFromRenderStep(v3.RenderStepName)
		self._camera.CameraType = v3.PreviousCameraType

		if v3.IsFieldOfViewControlled then
			self._camera.FieldOfView = v3.PreviousFieldOfView
		end

		v2[self._camera] = nil
	elseif v3 then
		syncCameraOwnership(v3)
		applyFieldOfView(v3)
	end

	self._maid:DoCleaning()
end

return CameraController