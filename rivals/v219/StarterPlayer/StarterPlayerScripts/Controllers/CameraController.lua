local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
game:GetService("GuiService")
local RunService = game:GetService("RunService")
local VRService = game:GetService("VRService")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local QuaternionSpring = require(ReplicatedStorage.Modules.QuaternionSpring)
local GameplayUtility = require(ReplicatedStorage.Modules.GameplayUtility)
require(ReplicatedStorage.Modules.DebugLibrary)
local InputLibrary = require(ReplicatedStorage.Modules.InputLibrary)
require(ReplicatedStorage.Modules.TaskLibrary)
require(ReplicatedStorage.Modules.TestLibrary)
local Quaternion = require(ReplicatedStorage.Modules.Quaternion)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Spring = require(ReplicatedStorage.Modules.Spring)
local Signal = require(ReplicatedStorage.Modules.Signal)
require(Players.LocalPlayer.PlayerScripts.Controllers.PrivateServerController)
local UserInterfaceController = require(Players.LocalPlayer.PlayerScripts.Controllers.UserInterfaceController)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local ControlsController = require(Players.LocalPlayer.PlayerScripts.Controllers.ControlsController)
local SettingsController = require(Players.LocalPlayer.PlayerScripts.Controllers.SettingsController)
local DebugState = require(Players.LocalPlayer.PlayerScripts.Controllers.DebugController.DebugState)
local CameraShaker = require(Players.LocalPlayer.PlayerScripts.Modules.CameraShaker)
local CameraState = require(script:WaitForChild("CameraState"))
local value = Enum.RenderPriority.Camera.Value
local v = Vector2.new(0.77, 1) * 0.008726646259971648
local v2 = {
	MouseKeyboard = 1,
	Touch = 0.875,
	Gamepad = 0.75
}
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self.StateChanged = Signal.new()
	self.ActiveStateChanged = Signal.new()
	self.POVStateChanged = Signal.new()
	self.CustomFreecamStateChanged = Signal.new()
	self.RotationDeltaApplied = Signal.new()
	self.SubjectChanged = Signal.new()
	self.CameraState = CameraState.new(self)
	self.Rotation = Vector2.zero
	self.ShakeCFrame = CFrame.identity
	self.ViewModelOffsetCFrame = CFrame.identity
	self.VRCameraCFrame = nil
	self._current_subject = nil
	self._current_duel_subject = nil
	self._third_person_override = nil
	self._external_fov_offsets = {}
	self._is_editing_mobile_buttons = false
	self._last_dt = 0
	self._last_mouse_behavior = nil
	self._gamepad_rotation_input = Vector2.zero
	self._bobbing_tick = 0
	self._fov_gameplay_spring = Spring.new(60, 0.75, 30)
	self._fov_weapons_spring = Spring.new(0, 1, 20)
	self._position_spring = Spring.new(createVector(0, 0, 0), 0.75, 30)
	self._pov_spring = Spring.new(createVector(0, 0, 0), 0.875, 25)
	self._sway_spring = Spring.new(Vector2.zero, 0.5, 12.5)
	self._bobbing_speed_spring = Spring.new(0, 0.5, 12.5)
	self._bobbing_value_spring = Spring.new(0, 0.75, 12.5)
	self._jump_spring = Spring.new(0, 0.5, 15)
	self._sliding_spring = Spring.new(0, 0.5, 15)
	self._leaning_spring = Spring.new(0, 1, 20)
	self._camera_shaker = nil
	self._collision_whitelist = {}
	self._next_collision_whitelist_fetch = 0
	self._viewmodel_animation_spring = QuaternionSpring.new(Quaternion.fromCFrame(CFrame.identity), 1, 10)
	self._crosshair_disabled = false
	self._base_fov = 80
	self._gameplay_fov_effects_enabled = true
	self._shake_enabled = true
	self._open_playerlist_input_down = false
	self._inverted_identity_vector = Vector2.one
	self._camera_sensitivity = 1
	self._camera_sensitivity_ads_multiplier = 1
	self._camera_sensitivity_ads_multiplier_scoped = 1
	self._camera_sensitivity_x = 1
	self._camera_sensitivity_y = 1
	self._fov_offset_strength = 0
	self._fov_offset_strength_scoped = 0
	self._gamepad_deadzone = 0.25
	self:_Init()
	return self
end

function class:GetPublicState(...)
	return self.CameraState:GetPublicState(...)
end

function class:GetCurrentSubject()
	return self._current_subject
end

function class:IsSubjectEmoting()
	local currentSubject = self:GetCurrentSubject()
	return currentSubject and currentSubject.Entity and currentSubject.Entity:IsEmoting()
end

function class:HasThirdPersonAccess(p)
	if self._third_person_override ~= nil then
		return self._third_person_override
	end

	if self._current_subject and self._current_subject:Get("CheaterMode") then
		return true
	end

	if p or not self:IsSubjectEmoting() then
		return DebugState:Get("AreHandicapsEnabled") or ControlsController.CurrentControls == "Touch"
	end

	return true
end

function class:HasUnlockedMouseAccess()
	return self:HasThirdPersonAccess() and (ControlsController.CurrentControls == "MouseKeyboard" or self:IsSubjectEmoting())
end

function class:GetLastHeartbeatDeltaTime()
	return self._last_dt
end

function class.GetRenderstepPriority(_)
	return value
end

function class:GetCameraCFrame(p)
	local v3 = p or self._current_subject

	if ControlsController.CurrentControls == "VR" then
		return workspace.CurrentCamera.CFrame * self.VRCameraCFrame
	end

	if not (v3 and v3.Entity) then
		return CFrame.identity
	end

	local v4

	if self.CameraState:GetPublicState() == self.CameraState.States.FirstPerson then
		v4 = CFrame.new(self._leaning_spring.Value * createVector(2, 0.1, 0))
	else
		v4 = CFrame.identity
	end

	return CFrame.new(v3.Entity.RootPart.Position) * CFrame.new(self._position_spring.Value) * self:GetRotationCFrame() * v4
end

function class:GetRotationCFrame(p2)
	local v3 = p2 or self.Rotation
	return CFrame.Angles(0, v3.Y, 0) * CFrame.Angles(v3.X, 0, 0)
end

function class:GetGamepadRotationInput(p2)
	return p2 and Vector2.new(self._gamepad_rotation_input.Y, self._gamepad_rotation_input.X) or self._gamepad_rotation_input
end

function class:GetExternalFOVOffset()
	local total = 0

	for _, _external_fov_offset in pairs(self._external_fov_offsets) do
		total += _external_fov_offset
	end

	return total
end

function class:GetCameraSensitivity()
	local isAiming = self._current_subject and self._current_subject.EquippedItem and self._current_subject.EquippedItem:Get("IsAiming")
	local aimScopePercent = self._current_subject and self._current_subject.EquippedItem and self._current_subject.EquippedItem.Info.AimScopePercent
	local v3

	if isAiming and aimScopePercent then
		v3 = self._camera_sensitivity_ads_multiplier_scoped
	else
		v3 = not isAiming and 1 or self._camera_sensitivity_ads_multiplier
	end

	return self._camera_sensitivity * (v3 or 1)
end

function class:SetRotation(p2)
	if self._current_subject and self._current_subject.Entity and self._current_subject.Entity:Get("IsFrozen") then
		return
	end

	self.Rotation = Vector2.new(math.clamp(p2.X, -1.5690509975429023, 1.5690509975429023), p2.Y)
end

function class:SetSubject(current_subject)
	self._current_subject = current_subject
	self.SubjectChanged:Fire()
end

function class:SetDuelSubject(current_duel_subject)
	self._current_duel_subject = current_duel_subject
end

function class:SetExternalFOVOffset(p2, p3)
	local _external_fov_offsets = self._external_fov_offsets

	if p3 == 0 then
		p3 = nil
	end

	_external_fov_offsets[p2] = p3
end

function class:SetThirdPersonOverride(third_person_override)
	self._third_person_override = third_person_override
	self.CameraState:VerifyPOV()
end

function class:SetIsEditingMobileButtons(is_editing_mobile_buttons)
	self._is_editing_mobile_buttons = is_editing_mobile_buttons
end

function class:Freeze(isFrozen)
	if isFrozen and not self.IsFrozen then
		UserInputService.MouseIconEnabled = true
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	elseif not isFrozen and self.IsFrozen then
		self._last_mouse_behavior = nil
	end

	self.IsFrozen = isFrozen
	self:Update(0)
end

function class:ApplyRotationDelta(p, p2)
	local v3

	if p2 then
		v3 = Vector2.one
	else
		v3 = self._inverted_identity_vector * self:GetCameraSensitivity() * Vector2.new(
			self._camera_sensitivity_y,
			self._camera_sensitivity_x
		)
	end

	local v4 = p * v3
	self:SetRotation(self.Rotation + v4)
	self.RotationDeltaApplied:Fire(v4)
end

function class:ShakeOnce(...)
	self._camera_shaker:ShakeOnce(...)
end

function class:Shake(...)
	self._camera_shaker:Shake(...)
end

function class:MimicRotation(cframe)
	local orientation, v3, _ = cframe:ToOrientation()
	self:SetRotation(Vector2.new(orientation, v3))
end

function class:Update(value2)
	if self.IsFrozen or self.CameraState:GetPublicState() == self.CameraState.States.CustomFreecam then
		return
	end

	local v3 = value2 or 0
	local _current_subject

	if self._current_subject == nil then
		_current_subject = false
	else
		_current_subject = self._current_subject:IsAlive() and self._current_subject
	end

	self.CameraState:SetActive(_current_subject and _current_subject:IsActive())
	local publicState = self.CameraState:GetPublicState()
	local spectatePart

	if not publicState and self._current_duel_subject and not self._current_duel_subject.LocalDueler then
		spectatePart = self._current_duel_subject.Map and self._current_duel_subject.Map:GetSpectatePart() or CollectionService:GetTagged("WaitingRoomSpectate")[1]
	end

	if spectatePart then
		UserInputService.MouseIconEnabled = true
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		workspace.CurrentCamera.CameraSubject = nil
		workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
		workspace.CurrentCamera.CFrame = spectatePart.CFrame
	else
		local v4 = publicState == self.CameraState.States.ThirdPersonUnlockedMouse or not (_current_subject and _current_subject.IsLocalPlayer)
		local v5 = publicState and publicState ~= self.CameraState.States.ThirdPersonUnlockedMouse
		local equippedItem = _current_subject and _current_subject.EquippedItem
		local _Modal = self:_Modal()
		local v6 = _Modal and ControlsController.CurrentControls == "MouseKeyboard"
		local lockCenter = v5 and not v4 and ControlsController.CurrentControls == "MouseKeyboard" and not v6 and Enum.MouseBehavior.LockCenter or Enum.MouseBehavior.Default
		local cameraType = workspace.CurrentCamera.CameraType
		local currentCamera = workspace.CurrentCamera
		local cameraSubject

		if _current_subject and _current_subject.Entity then
			cameraSubject = _current_subject.Entity.Humanoid or nil
		end

		currentCamera.CameraSubject = cameraSubject
		workspace.CurrentCamera.CameraType = v5 and Enum.CameraType.Scriptable or Enum.CameraType.Custom
		UserInputService.MouseIconEnabled = v6 or not (equippedItem and _current_subject) or not _current_subject.IsLocalPlayer or ControlsController.CurrentControls == "Touch" or self._crosshair_disabled and v4 or self:IsSubjectEmoting()

		if lockCenter == Enum.MouseBehavior.LockCenter or lockCenter ~= self._last_mouse_behavior then
			UserInputService.MouseBehavior = lockCenter
			self._last_mouse_behavior = lockCenter
		end

		if not v5 then
			self:MimicRotation(workspace.CurrentCamera.CFrame.Rotation * CFrame.Angles(0.17453292519943295, 0, 0))
		end

		if not _current_subject then
			workspace.CurrentCamera.FieldOfView = self._base_fov
			return
		end

		local cframe = CFrame.new(_current_subject.Entity.RootPart.Position)
		local v8

		if cameraType == Enum.CameraType.Custom and workspace.CurrentCamera.CameraType ~= Enum.CameraType.Custom then
			v8 = (workspace.CurrentCamera.CFrame.Position - cframe.Position).Magnitude < 128
		else
			v8 = false
		end

		if v8 then
			self._fov_gameplay_spring.Value = workspace.CurrentCamera.FieldOfView
		end

		local isLocalPlayer = _current_subject.IsLocalPlayer
		_current_subject:IsSprinting()
		local isCrouching = _current_subject:IsCrouching()
		local isSliding = _current_subject:IsSliding()
		local isGrounded = _current_subject:IsGrounded()
		local v9 = _current_subject and _current_subject.Entity and _current_subject.Entity.Humanoid and _current_subject.Entity.Humanoid:GetState() == Enum.HumanoidStateType.Climbing
		local rotationCFrame = _current_subject:GetRotationCFrame()
		local v10 = _current_subject:GetCameraSway() * 0.25
		local cameraLean = _current_subject:GetCameraLean()
		local clampedVelocity = _current_subject.Entity:GetClampedVelocity()
		local magnitude = (clampedVelocity * createVector(1, 0, 1)).Magnitude
		local _fov_offset_strength_scoped

		if equippedItem and equippedItem.Info.AimScopePercent then
			_fov_offset_strength_scoped = self._fov_offset_strength_scoped
		else
			_fov_offset_strength_scoped = self._fov_offset_strength
		end

		self._fov_weapons_spring.Speed = 20 * _current_subject:GetAimSpeed()
		self._fov_weapons_spring.Target = publicState == self.CameraState.States.ThirdPersonUnlockedMouse and 0 or _current_subject:GetFOVOffset() * _fov_offset_strength_scoped
		self._fov_gameplay_spring.Target = self._base_fov + (not self._gameplay_fov_effects_enabled and 0 or math.max(
			0,
			magnitude - CONSTANTS.BASE_WALKSPEED
		) * 10 / CONSTANTS.BASE_WALKSPEED or 0) + self:GetExternalFOVOffset()
		local fieldOfView = self._fov_gameplay_spring.Value + self._fov_weapons_spring.Value * (self._fov_gameplay_spring.Value / 80)
		workspace.CurrentCamera.FieldOfView = fieldOfView
		self._position_spring.Target = createVector(0, 1.75, 0) + Vector3.new(
			0,
			isSliding and -3 or v9 and -2.5 or isCrouching and -2 or 0,
			0
		)

		if workspace.CurrentCamera.CameraType ~= Enum.CameraType.Scriptable then
			return
		end

		if v8 then
			self._position_spring.Value = workspace.CurrentCamera.CFrame:ToObjectSpace(cframe):Inverse().Position * 0.5
		end

		if ControlsController.CurrentControls == "Gamepad" and not (_Modal or UserInterfaceController:IsPageOpen()) then
			self:ApplyRotationDelta(self._gamepad_rotation_input * self:_GetFOVMultiplier() * v3 * 60)
		end

		local cframe2 = CFrame.new(self._position_spring.Value)
		local identity = CFrame.identity
		local identity2 = CFrame.identity

		if publicState == self.CameraState.States.FirstPerson and not isLocalPlayer then
			self._bobbing_speed_spring.Target = magnitude / CONSTANTS.BASE_WALKSPEED * (isGrounded and 1 or 0) * 0.111
			self._bobbing_tick += self._bobbing_speed_spring.Value * v3 * 60
			self._bobbing_value_spring.Target = (math.abs((math.sin(self._bobbing_tick))) - 0.5) * (magnitude / CONSTANTS.BASE_WALKSPEED) ^ 2 * (isSliding and 0 or 1) * 0.125
			local value3 = self._bobbing_value_spring.Value
			identity = CFrame.new(0, value3, 0)
			identity2 = CFrame.Angles(value3 * 0.08726646259971647, 0, 0)
		end

		local value3 = self._pov_spring.Value
		local cframe3 = CFrame.new(value3)
		self._sway_spring.Value += Vector2.new(v10.Y * 0.5, v10.X)
		local v12 = self._sway_spring.Value * (isLocalPlayer and 0 or 0.025)
		local cframe4 = CFrame.Angles(v12.X, 0, v12.Y)
		local identity3 = isLocalPlayer and CFrame.identity or CFrame.Angles(
			math.sin(tick() * 0.23983 % 6.283185307179586) * 0.004363323129985824,
			math.sin(tick() * 0.372721 % 6.283185307179586) * 0.004363323129985824,
			math.sin(tick() * 0.43123 % 6.283185307179586) * 0.004363323129985824
		)
		self._jump_spring.Target = clampedVelocity.Y
		local v13 = self._jump_spring.Value / CONSTANTS.BASE_GRAVITY * (isLocalPlayer and 0 or 0.5)
		local cframe5 = CFrame.Angles(math.clamp(math.rad(-v13 / 15), -0.7853981633974483, 0.7853981633974483), 0, 0)
		self._sliding_spring.Target = isSliding and 1 or 0
		local value4 = self._sliding_spring.Value
		local cframe6 = CFrame.Angles(0, 0, -0.08726646259971647 * value4)
		self._leaning_spring.Target = publicState == self.CameraState.States.FirstPerson and cameraLean or 0
		local value5 = self._leaning_spring.Value
		local v14 = CFrame.new(value5 * createVector(2, 0.1, 0)) * CFrame.Angles(0, 0, value5 * -0.08726646259971647)
		self._viewmodel_animation_spring.Target = Quaternion.fromCFrame(equippedItem and equippedItem.ViewModel and equippedItem.ViewModel:GetCameraOffset() or CFrame.identity)
		self.ViewModelOffsetCFrame = CFrame.identity
		local v15 = cframe * cframe2 * (identity * rotationCFrame * identity2 * cframe3 * cframe4 * identity3 * cframe5 * cframe6 * v14 * self.ViewModelOffsetCFrame * self.ShakeCFrame)
		local position = v15.Position

		if tick() > self._next_collision_whitelist_fetch then
			self._next_collision_whitelist_fetch = tick() + 5
			self._collision_whitelist = GameplayUtility:GetRaycastWhitelist(_current_subject:Get("EnvironmentID"))
		end

		local raycastResult = Utility:Raycast(
			_current_subject.Entity.RootPart.Position,
			v15.Position,
			(v15.Position - _current_subject.Entity.RootPart.Position).Magnitude,
			self._collision_whitelist,
			Enum.RaycastFilterType.Include
		)

		if raycastResult.Instance then
			position = _current_subject.Entity.RootPart.Position + (v15.Position - _current_subject.Entity.RootPart.Position).Unit * ((_current_subject.Entity.RootPart.Position - raycastResult.Position).Magnitude - 0.5)
		end

		workspace.CurrentCamera.CFrame = CFrame.new(position) * v15.Rotation
	end
end

function class:_UpdateSettings()
	self._crosshair_disabled = PlayerDataController:GetSetting("Crosshair Disabled")
	self._base_fov = PlayerDataController:GetSetting("Camera FOV")
	self._gameplay_fov_effects_enabled = PlayerDataController:GetSetting("Camera FOV Effects")
	self._shake_enabled = PlayerDataController:GetSetting("Camera Shake")
	self._inverted_identity_vector = Vector2.new(
		PlayerDataController:GetSetting("Camera Inverted Y") and -1 or 1,
		PlayerDataController:GetSetting("Camera Inverted X") and -1 or 1
	)
	self._camera_sensitivity = PlayerDataController:GetSetting("Camera Sensitivity")
	self._camera_sensitivity_ads_multiplier = PlayerDataController:GetSetting("Camera Sensitivity ADS")
	self._camera_sensitivity_ads_multiplier_scoped = PlayerDataController:GetSetting("Camera Sensitivity Scoped")
	self._camera_sensitivity_x = PlayerDataController:GetSetting("Camera Sensitivity X")
	self._camera_sensitivity_y = PlayerDataController:GetSetting("Camera Sensitivity Y")
	self._fov_offset_strength = PlayerDataController:GetSetting("Camera Zoom Effects")
	self._fov_offset_strength_scoped = PlayerDataController:GetSetting("Camera Zoom Effects Scoped")
	self._gamepad_deadzone = PlayerDataController:GetSetting("Gamepad Deadzone")
end

function class:_Modal()
	return self._current_duel_subject and self._current_duel_subject.DuelInterface and self._current_duel_subject.DuelInterface.Scoreboard:IsOpen() or UserInterfaceController:IsPageOpen() or self._open_playerlist_input_down
end

function class:_GetFOVMultiplier()
	return workspace.CurrentCamera.FieldOfView < self._base_fov and workspace.CurrentCamera.FieldOfView / self._base_fov or 1
end

function class:_InputChanged(data, p)
	if p or self._is_editing_mobile_buttons or ControlsController.CurrentControls == "MouseKeyboard" and data.UserInputType ~= Enum.UserInputType.MouseMovement and data.UserInputType ~= Enum.UserInputType.MouseWheel then
		return
	end

	local v3 = v2[ControlsController.CurrentControls]

	if ControlsController.CurrentControls == "MouseKeyboard" or ControlsController.CurrentControls == "Touch" then
		self:ApplyRotationDelta(Vector2.new(data.Delta.Y, data.Delta.X) * v * v3 * self:_GetFOVMultiplier() * -1)
	elseif ControlsController.CurrentControls == "Gamepad" and (data.KeyCode == Enum.KeyCode.Thumbstick1 or data.KeyCode == Enum.KeyCode.Thumbstick2) then
		local v4 = math.max(
			0,
			(Vector2.new(data.Position.X, data.Position.Y).Magnitude - self._gamepad_deadzone) / (1 - self._gamepad_deadzone)
		)
		local v5 = data.Position.X * v4
		local v6 = math.floor(data.Position.Y * v4 * 10 + 0.5) * v3
		local v7 = -math.floor(v5 * 10 + 0.5) * v3
		self._gamepad_rotation_input = Vector2.new(v6, v7) * 0.01
	end
end

function class:_Setup()
	if VRService:GetUserCFrameEnabled(Enum.UserCFrame.RightHand) then
		self.VRCameraCFrame = VRService:GetUserCFrame(Enum.UserCFrame.RightHand)
	end

	self._camera_shaker = CameraShaker.new(Enum.RenderPriority.Camera.Value + 1, function(p)
		self.ShakeCFrame = self._shake_enabled and p or CFrame.identity
	end)
	self._camera_shaker:Start()
end

function class:_Init()
	self.StateChanged:Connect(function()
		local publicState = self.CameraState:GetPublicState()
		self._pov_spring.Target = publicState == self.CameraState.States.ThirdPerson and createVector(3, 1.5, 7.5) or publicState == self.CameraState.States.ThirdPersonMirrored and createVector(
			-3,
			1.5,
			7.5
		) or publicState == self.CameraState.States.ThirdPersonUnlockedMouse and createVector(0, 3, 10) or createVector(
			0,
			0,
			0
		)
	end)
	self.CameraState.StateChanged:Connect(function(p, p2)
		self.StateChanged:Fire(p, p2)

		if not (p and p2) then
			self.ActiveStateChanged:Fire(p, p2)
		end

		if p == self.CameraState.States.CustomFreecam or p2 == self.CameraState.States.CustomFreecam then
			self.CustomFreecamStateChanged:Fire(p, p2)
		end

		local index = table.find(self.CameraState.POVStates, p)
		local index2 = table.find(self.CameraState.POVStates, p2)

		if index or index2 then
			self.POVStateChanged:Fire(p, p2, index and index2)
		end
	end)
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		local publicState = self.CameraState:GetPublicState()
		local v3

		if publicState == self.CameraState.States.CustomFreecam then
			v3 = Utility:IsTextBoxFocused()
		else
			v3 = gameProcessed
		end

		if not v3 and InputLibrary:InputIs(input, "HideHUD") then
			SettingsController:ChangeSetting("Hide HUD", not PlayerDataController:GetSetting("Hide HUD"))
		end

		if self.IsFrozen or not publicState then
			return
		end

		if gameProcessed or not InputLibrary:InputIs(input, "SwitchCameraPOV") then
			if not gameProcessed and InputLibrary:InputIs(input, "OpenPlayerList") then
				self._open_playerlist_input_down = true
			end
		else
			self.CameraState:TogglePOV()
		end
	end)
	UserInputService.InputChanged:Connect(function(...)
		if self.IsFrozen or not self.CameraState:GetPublicState() then
			return
		end

		self:_InputChanged(...)
	end)
	UserInputService.InputEnded:Connect(function(input, _)
		if InputLibrary:InputIs(input, "OpenPlayerList") then
			self._open_playerlist_input_down = false
		end
	end)
	VRService.UserCFrameChanged:Connect(function(_, _)
		if self.IsFrozen or not self.CameraState:GetPublicState() then
			return
		end

		local userCFrame = VRService:GetUserCFrameEnabled(Enum.UserCFrame.RightHand) and VRService:GetUserCFrame(Enum.UserCFrame.RightHand)
		local userCFrame2 = VRService:GetUserCFrameEnabled(Enum.UserCFrame.Head) and VRService:GetUserCFrame(Enum.UserCFrame.Head)
		local v3 = userCFrame2 or userCFrame or CFrame.identity
		local v4 = userCFrame or userCFrame2 or CFrame.identity
		self.VRCameraCFrame = CFrame.new(v3.Position) * (v4 - v4.Position)
	end)
	RunService:BindToRenderStep("CameraController", value, function(last_dt)
		self._last_dt = last_dt
		self:Update(last_dt)
	end)
	PlayerDataController:GetSettingChangedSignal("Crosshair Disabled"):Connect(function()
		self:_UpdateSettings()
	end)
	PlayerDataController:GetSettingChangedSignal("Camera FOV"):Connect(function()
		self:_UpdateSettings()
	end)
	PlayerDataController:GetSettingChangedSignal("Camera FOV Effects"):Connect(function()
		self:_UpdateSettings()
	end)
	PlayerDataController:GetSettingChangedSignal("Camera Inverted X"):Connect(function()
		self:_UpdateSettings()
	end)
	PlayerDataController:GetSettingChangedSignal("Camera Inverted Y"):Connect(function()
		self:_UpdateSettings()
	end)
	PlayerDataController:GetSettingChangedSignal("Camera Shake"):Connect(function()
		self:_UpdateSettings()
	end)
	PlayerDataController:GetSettingChangedSignal("Camera Sensitivity"):Connect(function()
		self:_UpdateSettings()
	end)
	PlayerDataController:GetSettingChangedSignal("Camera Sensitivity ADS"):Connect(function()
		self:_UpdateSettings()
	end)
	PlayerDataController:GetSettingChangedSignal("Camera Zoom Effects"):Connect(function()
		self:_UpdateSettings()
	end)
	PlayerDataController:GetSettingChangedSignal("Camera Zoom Effects Scoped"):Connect(function()
		self:_UpdateSettings()
	end)
	PlayerDataController:GetSettingChangedSignal("Gamepad Deadzone"):Connect(function()
		self:_UpdateSettings()
	end)
	PlayerDataController:GetSettingChangedSignal("Camera Sensitivity X"):Connect(function()
		self:_UpdateSettings()
	end)
	PlayerDataController:GetSettingChangedSignal("Camera Sensitivity Y"):Connect(function()
		self:_UpdateSettings()
	end)
	PlayerDataController:GetSettingChangedSignal("Camera Sensitivity Scoped"):Connect(function()
		self:_UpdateSettings()
	end)
	PlayerDataController.SettingsSliderChanged:Connect(function(p, base_fov)
		if p == "Camera FOV" then
			self._base_fov = base_fov
		end
	end)
	self:_Setup()
	self:_UpdateSettings()
end

return class._new()