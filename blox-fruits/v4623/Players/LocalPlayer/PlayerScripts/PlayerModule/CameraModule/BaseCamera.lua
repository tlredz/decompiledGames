local createVector = vector.create
local vector2 = Vector2.new(0.2617993877991494, 0)
local vector3 = Vector2.new(0.7853981633974483, 0)
local vector4 = Vector2.new(0, 0)
local success, result = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserTouchSensitivityAdjust")
end)
local v = success and result
local vector5 = Vector2.new(0.014137166941154067, 0.010602875205865551)

if v then
	vector5 = Vector2.new(0.029688050576423545, 0.010602875205865551)
end

local vector6 = Vector2.new(0.006283185307179587, 0.00471238898038469)
local abs = math.abs
local _ = math.sign
local success2, result2 = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserThirdGamepadZoomStep")
end)
local v2 = success2 and result2
local success3, result3 = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserPointerActionsInPlayerScripts")
end)
local v3 = success3 and result3
local success4, result4 = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserNoMoreKeyboardPan")
end)
local v4 = success4 and result4
local success5, result5 = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserFixZoomClampingIssues")
end)
local v5 = success5 and result5
local CameraUtils = require(script.Parent:WaitForChild("CameraUtils"))
local ZoomController = require(script.Parent:WaitForChild("ZoomController"))
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local GuiService = game:GetService("GuiService")
local ContextActionService = game:GetService("ContextActionService")
local VRService = game:GetService("VRService")
local UserGameSettings = UserSettings():GetService("UserGameSettings")
local BaseCamera = {}
BaseCamera.__index = BaseCamera

function BaseCamera.new()
	local object = setmetatable({}, BaseCamera)
	object.FIRST_PERSON_DISTANCE_THRESHOLD = 1
	object.cameraType = nil
	object.cameraMovementMode = nil
	local localPlayer = Players.LocalPlayer
	object.lastCameraTransform = nil
	object.rotateInput = vector4
	object.userPanningCamera = false
	object.lastUserPanCamera = tick()
	object.humanoidRootPart = nil
	object.humanoidCache = {}
	object.lastSubject = nil
	object.lastSubjectPosition = createVector(0, 5, 0)
	object.defaultSubjectDistance = CameraUtils.Clamp(
		localPlayer.CameraMinZoomDistance,
		localPlayer.CameraMaxZoomDistance,
		12.5
	)
	object.currentSubjectDistance = CameraUtils.Clamp(
		localPlayer.CameraMinZoomDistance,
		localPlayer.CameraMaxZoomDistance,
		12.5
	)
	object.inFirstPerson = false
	object.inMouseLockedMode = false
	object.portraitMode = false
	object.isSmallTouchScreen = false
	object.resetCameraAngle = true
	object.enabled = false
	object.inputBeganConn = nil
	object.inputChangedConn = nil
	object.inputEndedConn = nil
	object.startPos = nil
	object.lastPos = nil
	object.panBeginLook = nil
	object.panEnabled = true
	object.keyPanEnabled = true
	object.distanceChangeEnabled = true
	object.PlayerGui = nil
	object.cameraChangedConn = nil
	object.viewportSizeChangedConn = nil
	object.boundContextActions = {}
	object.shouldUseVRRotation = false
	object.VRRotationIntensityAvailable = false
	object.lastVRRotationIntensityCheckTime = 0
	object.lastVRRotationTime = 0
	object.vrRotateKeyCooldown = {}
	object.cameraTranslationConstraints = createVector(1, 1, 1)
	object.humanoidJumpOrigin = nil
	object.trackingHumanoid = nil
	object.cameraFrozen = false
	object.subjectStateChangedConn = nil
	object.activeGamepad = nil
	object.gamepadPanningCamera = false
	object.lastThumbstickRotate = nil
	object.numOfSeconds = 0.7
	object.currentSpeed = 0
	object.maxSpeed = 6
	object.vrMaxSpeed = 4
	object.lastThumbstickPos = Vector2.new(0, 0)
	object.ySensitivity = 0.65
	object.lastVelocity = nil
	object.gamepadConnectedConn = nil
	object.gamepadDisconnectedConn = nil
	object.currentZoomSpeed = 1
	object.L3ButtonDown = false
	object.dpadLeftDown = false
	object.dpadRightDown = false
	object.isDynamicThumbstickEnabled = false
	object.fingerTouches = {}
	object.dynamicTouchInput = nil
	object.numUnsunkTouches = 0
	object.inputStartPositions = {}
	object.inputStartTimes = {}
	object.startingDiff = nil
	object.pinchBeginZoom = nil
	object.userPanningTheCamera = false
	object.touchActivateConn = nil
	object.mouseLockOffset = createVector(0, 0, 0)

	if localPlayer.Character then
		object:OnCharacterAdded(localPlayer.Character)
	end

	localPlayer.CharacterAdded:Connect(function(character)
		object:OnCharacterAdded(character)
	end)

	if object.cameraChangedConn then
		object.cameraChangedConn:Disconnect()
	end

	object.cameraChangedConn = workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		object:OnCurrentCameraChanged()
	end)
	object:OnCurrentCameraChanged()

	if object.playerCameraModeChangeConn then
		object.playerCameraModeChangeConn:Disconnect()
	end

	object.playerCameraModeChangeConn = localPlayer:GetPropertyChangedSignal("CameraMode"):Connect(function()
		object:OnPlayerCameraPropertyChange()
	end)

	if object.minDistanceChangeConn then
		object.minDistanceChangeConn:Disconnect()
	end

	object.minDistanceChangeConn = localPlayer:GetPropertyChangedSignal("CameraMinZoomDistance"):Connect(function()
		object:OnPlayerCameraPropertyChange()
	end)

	if object.maxDistanceChangeConn then
		object.maxDistanceChangeConn:Disconnect()
	end

	object.maxDistanceChangeConn = localPlayer:GetPropertyChangedSignal("CameraMaxZoomDistance"):Connect(function()
		object:OnPlayerCameraPropertyChange()
	end)

	if object.playerDevTouchMoveModeChangeConn then
		object.playerDevTouchMoveModeChangeConn:Disconnect()
	end

	object.playerDevTouchMoveModeChangeConn = localPlayer:GetPropertyChangedSignal("DevTouchMovementMode"):Connect(function()
		object:OnDevTouchMovementModeChanged()
	end)
	object:OnDevTouchMovementModeChanged()

	if object.gameSettingsTouchMoveMoveChangeConn then
		object.gameSettingsTouchMoveMoveChangeConn:Disconnect()
	end

	object.gameSettingsTouchMoveMoveChangeConn = UserGameSettings:GetPropertyChangedSignal("TouchMovementMode"):Connect(function()
		object:OnGameSettingsTouchMovementModeChanged()
	end)
	object:OnGameSettingsTouchMovementModeChanged()
	UserGameSettings:SetCameraYInvertVisible()
	UserGameSettings:SetGamepadCameraSensitivityVisible()
	object.hasGameLoaded = game:IsLoaded()

	if not object.hasGameLoaded then
		object.gameLoadedConn = game.Loaded:Connect(function()
			object.hasGameLoaded = true
			object.gameLoadedConn:Disconnect()
			object.gameLoadedConn = nil
		end)
	end

	if v5 then
		object:OnPlayerCameraPropertyChange()
	end

	return object
end

function BaseCamera.GetModuleName(_)
	return "BaseCamera"
end

function BaseCamera:OnCharacterAdded(instance)
	self.resetCameraAngle = self.resetCameraAngle or self:GetEnabled()
	self.humanoidRootPart = nil

	if UserInputService.TouchEnabled then
		self.PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

		for _, tool in ipairs(instance:GetChildren()) do
			if tool:IsA("Tool") then
				self.isAToolEquipped = true
			end
		end

		instance.ChildAdded:Connect(function(tool)
			if tool:IsA("Tool") then
				self.isAToolEquipped = true
			end
		end)
		instance.ChildRemoved:Connect(function(tool)
			if tool:IsA("Tool") then
				self.isAToolEquipped = false
			end
		end)
	end
end

function BaseCamera:GetHumanoidRootPart()
	if self.humanoidRootPart then
		return self.humanoidRootPart
	end

	local localPlayer = Players.LocalPlayer
	local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		self.humanoidRootPart = humanoid.RootPart
	end

	return self.humanoidRootPart
end

function BaseCamera.GetBodyPartToFollow(_, object, _)
	if object:GetState() == Enum.HumanoidStateType.Dead then
		local parent = object.Parent

		if parent and parent:IsA("Model") then
			return parent:FindFirstChild("Head") or object.RootPart
		end
	end

	return object.RootPart
end

function BaseCamera:GetSubjectPosition()
	local lastSubjectPosition = self.lastSubjectPosition
	local currentCamera = game.Workspace.CurrentCamera
	local cameraSubject = currentCamera and currentCamera.CameraSubject

	if not cameraSubject then
		return
	end

	if cameraSubject:IsA("Humanoid") then
		local v6 = cameraSubject:GetState() == Enum.HumanoidStateType.Dead

		if VRService.VREnabled and v6 and cameraSubject == self.lastSubject then
			lastSubjectPosition = self.lastSubjectPosition
		else
			local rootPart = cameraSubject.RootPart

			if v6 and cameraSubject.Parent and cameraSubject.Parent:IsA("Model") then
				rootPart = cameraSubject.Parent:FindFirstChild("Head") or rootPart
			end

			if rootPart and rootPart:IsA("BasePart") then
				local v7

				if cameraSubject.RigType == Enum.HumanoidRigType.R15 then
					if cameraSubject.AutomaticScalingEnabled then
						v7 = createVector(0, 1.5, 0)

						if rootPart == cameraSubject.RootPart then
							v7 += Vector3.new(0, cameraSubject.RootPart.Size.Y / 2 - 1, 0)
						end
					else
						v7 = createVector(0, 2, 0)
					end
				else
					v7 = createVector(0, 1.5, 0)
				end

				lastSubjectPosition = rootPart.CFrame.p + rootPart.CFrame:vectorToWorldSpace((v6 and createVector(
					0,
					0,
					0
				) or v7) + cameraSubject.CameraOffset)
			end
		end
	elseif cameraSubject:IsA("VehicleSeat") then
		local v6 = VRService.VREnabled and createVector(0, 4, 0) or createVector(0, 5, 0)
		lastSubjectPosition = cameraSubject.CFrame.p + cameraSubject.CFrame:vectorToWorldSpace(v6)
	elseif cameraSubject:IsA("SkateboardPlatform") then
		lastSubjectPosition = cameraSubject.CFrame.p + createVector(0, 5, 0)
	elseif cameraSubject:IsA("BasePart") then
		lastSubjectPosition = cameraSubject.CFrame.p
	elseif cameraSubject:IsA("Model") then
		if cameraSubject.PrimaryPart then
			lastSubjectPosition = cameraSubject:GetPrimaryPartCFrame().p
		else
			lastSubjectPosition = cameraSubject:GetModelCFrame().p
		end
	end

	self.lastSubject = cameraSubject
	self.lastSubjectPosition = lastSubjectPosition
	return lastSubjectPosition
end

function BaseCamera:UpdateDefaultSubjectDistance()
	local localPlayer = Players.LocalPlayer

	if self.portraitMode then
		self.defaultSubjectDistance = CameraUtils.Clamp(
			localPlayer.CameraMinZoomDistance,
			localPlayer.CameraMaxZoomDistance,
			25
		)
	else
		self.defaultSubjectDistance = CameraUtils.Clamp(
			localPlayer.CameraMinZoomDistance,
			localPlayer.CameraMaxZoomDistance,
			12.5
		)
	end
end

function BaseCamera:OnViewportSizeChanged()
	local viewportSize = game.Workspace.CurrentCamera.ViewportSize
	self.portraitMode = viewportSize.X < viewportSize.Y
	self.isSmallTouchScreen = UserInputService.TouchEnabled and (viewportSize.Y < 500 or viewportSize.X < 700)
	self:UpdateDefaultSubjectDistance()
end

function BaseCamera:OnCurrentCameraChanged()
	if UserInputService.TouchEnabled then
		if self.viewportSizeChangedConn then
			self.viewportSizeChangedConn:Disconnect()
			self.viewportSizeChangedConn = nil
		end

		local currentCamera = game.Workspace.CurrentCamera

		if currentCamera then
			self:OnViewportSizeChanged()
			self.viewportSizeChangedConn = currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
				self:OnViewportSizeChanged()
			end)
		end
	end

	if self.cameraSubjectChangedConn then
		self.cameraSubjectChangedConn:Disconnect()
		self.cameraSubjectChangedConn = nil
	end

	local currentCamera = game.Workspace.CurrentCamera

	if currentCamera then
		self.cameraSubjectChangedConn = currentCamera:GetPropertyChangedSignal("CameraSubject"):Connect(function()
			self:OnNewCameraSubject()
		end)
		self:OnNewCameraSubject()
	end
end

function BaseCamera:OnDynamicThumbstickEnabled()
	if UserInputService.TouchEnabled then
		self.isDynamicThumbstickEnabled = true
	end
end

function BaseCamera:OnDynamicThumbstickDisabled()
	self.isDynamicThumbstickEnabled = false
end

function BaseCamera:OnGameSettingsTouchMovementModeChanged()
	if Players.LocalPlayer.DevTouchMovementMode == Enum.DevTouchMovementMode.UserChoice then
		if UserGameSettings.TouchMovementMode == Enum.TouchMovementMode.DynamicThumbstick or UserGameSettings.TouchMovementMode == Enum.TouchMovementMode.Default then
			self:OnDynamicThumbstickEnabled()
		else
			self:OnDynamicThumbstickDisabled()
		end
	end
end

function BaseCamera:OnDevTouchMovementModeChanged()
	if Players.LocalPlayer.DevTouchMovementMode.Name == "DynamicThumbstick" then
		self:OnDynamicThumbstickEnabled()
	else
		self:OnGameSettingsTouchMovementModeChanged()
	end
end

function BaseCamera:OnPlayerCameraPropertyChange()
	self:SetCameraToSubjectDistance(self.currentSubjectDistance)
end

function BaseCamera.GetCameraHeight(p)
	if VRService.VREnabled and not p.inFirstPerson then
		return 0.25881904510252074 * p.currentSubjectDistance
	end

	return 0
end

function BaseCamera:InputTranslationToCameraAngleChange(p, p2)
	local currentCamera = game.Workspace.CurrentCamera

	if currentCamera and currentCamera.ViewportSize.X > 0 and currentCamera.ViewportSize.Y > 0 and currentCamera.ViewportSize.Y > currentCamera.ViewportSize.X then
		return p * Vector2.new(p2.Y, p2.X)
	end

	return p * p2
end

function BaseCamera:Enable(enabled)
	if self.enabled ~= enabled then
		self.enabled = enabled

		if self.enabled then
			self:ConnectInputEvents()
			self:BindContextActions()

			if Players.LocalPlayer.CameraMode == Enum.CameraMode.LockFirstPerson then
				self.currentSubjectDistance = 0.5

				if not self.inFirstPerson then
					self:EnterFirstPerson()
				end
			end
		else
			self:DisconnectInputEvents()
			self:UnbindContextActions()
			self:Cleanup()
		end
	end
end

function BaseCamera:GetEnabled()
	return self.enabled
end

function BaseCamera:OnInputBegan(p, p2)
	if p.UserInputType == Enum.UserInputType.Touch then
		self:OnTouchBegan(p, p2)
	elseif p.UserInputType == Enum.UserInputType.MouseButton2 then
		self:OnMouse2Down(p, p2)
	elseif p.UserInputType == Enum.UserInputType.MouseButton3 then
		self:OnMouse3Down(p, p2)
	end
end

function BaseCamera:OnInputChanged(p, p2)
	if p.UserInputType == Enum.UserInputType.Touch then
		self:OnTouchChanged(p, p2)
	elseif p.UserInputType == Enum.UserInputType.MouseMovement then
		self:OnMouseMoved(p, p2)
	elseif p.UserInputType == Enum.UserInputType.MouseWheel and not v3 then
		self:OnMouseWheel(p, p2)
	end
end

function BaseCamera:OnInputEnded(p, p2)
	if p.UserInputType == Enum.UserInputType.Touch then
		self:OnTouchEnded(p, p2)
	elseif p.UserInputType == Enum.UserInputType.MouseButton2 then
		self:OnMouse2Up(p, p2)
	elseif p.UserInputType == Enum.UserInputType.MouseButton3 then
		self:OnMouse3Up(p, p2)
	end
end

function BaseCamera:OnPointerAction(p, vector7, Y, p2)
	if p2 then
		return
	end

	if Y == 0 then
		Y = math.sign(vector7.Y)
		vector7 = Vector2.new()
	end

	if vector7.Magnitude > 0 then
		local vector8 = Vector2.new(1, UserGameSettings:GetCameraYInvertValue())
		local v6 = self:InputTranslationToCameraAngleChange(20 * vector7, vector6) * vector8
		self.rotateInput += v6
	end

	local currentSubjectDistance = self.currentSubjectDistance
	local v6 = -(p + Y)

	if abs(v6) > 0 then
		self:SetCameraToSubjectDistance(self.inFirstPerson and v6 > 0 and 1 or currentSubjectDistance + v6 * (1 + currentSubjectDistance * 0.5))
	end
end

function BaseCamera:ConnectInputEvents()
	if v3 then
		self.pointerActionConn = UserInputService.PointerAction:Connect(function(p, p2, p3, p4)
			self:OnPointerAction(p, p2, p3, p4)
		end)
	end

	self.inputBeganConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		self:OnInputBegan(input, gameProcessed)
	end)
	self.inputChangedConn = UserInputService.InputChanged:Connect(function(input, gameProcessed)
		self:OnInputChanged(input, gameProcessed)
	end)
	self.inputEndedConn = UserInputService.InputEnded:Connect(function(input, gameProcessed)
		self:OnInputEnded(input, gameProcessed)
	end)
	self.menuOpenedConn = GuiService.MenuOpened:connect(function()
		self:ResetInputStates()
	end)
	self.gamepadConnectedConn = UserInputService.GamepadDisconnected:connect(function(p)
		if self.activeGamepad ~= p then
			return
		end

		self.activeGamepad = nil
		self:AssignActivateGamepad()
	end)
	self.gamepadDisconnectedConn = UserInputService.GamepadConnected:connect(function(_)
		if self.activeGamepad == nil then
			self:AssignActivateGamepad()
		end
	end)
	self:AssignActivateGamepad()
	self:UpdateMouseBehavior()
end

function BaseCamera:BindContextActions()
	self:BindGamepadInputActions()
	self:BindKeyboardInputActions()
end

function BaseCamera:AssignActivateGamepad()
	local connectedGamepads = UserInputService:GetConnectedGamepads()

	if #connectedGamepads > 0 then
		for i = 1, #connectedGamepads do
			if self.activeGamepad == nil then
				self.activeGamepad = connectedGamepads[i]
			elseif connectedGamepads[i].Value < self.activeGamepad.Value then
				self.activeGamepad = connectedGamepads[i]
			end
		end
	end

	if self.activeGamepad == nil then
		self.activeGamepad = Enum.UserInputType.Gamepad1
	end
end

function BaseCamera:DisconnectInputEvents()
	if self.inputBeganConn then
		self.inputBeganConn:Disconnect()
		self.inputBeganConn = nil
	end

	if self.inputChangedConn then
		self.inputChangedConn:Disconnect()
		self.inputChangedConn = nil
	end

	if self.inputEndedConn then
		self.inputEndedConn:Disconnect()
		self.inputEndedConn = nil
	end
end

function BaseCamera:UnbindContextActions()
	for i = 1, #self.boundContextActions do
		ContextActionService:UnbindAction(self.boundContextActions[i])
	end

	self.boundContextActions = {}
end

function BaseCamera:Cleanup()
	if v3 and self.pointerActionConn then
		self.pointerActionConn:Disconnect()
		self.pointerActionConn = nil
	end

	if self.menuOpenedConn then
		self.menuOpenedConn:Disconnect()
		self.menuOpenedConn = nil
	end

	if self.mouseLockToggleConn then
		self.mouseLockToggleConn:Disconnect()
		self.mouseLockToggleConn = nil
	end

	if self.gamepadConnectedConn then
		self.gamepadConnectedConn:Disconnect()
		self.gamepadConnectedConn = nil
	end

	if self.gamepadDisconnectedConn then
		self.gamepadDisconnectedConn:Disconnect()
		self.gamepadDisconnectedConn = nil
	end

	if self.subjectStateChangedConn then
		self.subjectStateChangedConn:Disconnect()
		self.subjectStateChangedConn = nil
	end

	if self.viewportSizeChangedConn then
		self.viewportSizeChangedConn:Disconnect()
		self.viewportSizeChangedConn = nil
	end

	if self.touchActivateConn then
		self.touchActivateConn:Disconnect()
		self.touchActivateConn = nil
	end

	self.turningLeft = false
	self.turningRight = false
	self.lastCameraTransform = nil
	self.lastSubjectCFrame = nil
	self.userPanningTheCamera = false
	self.rotateInput = Vector2.new()
	self.gamepadPanningCamera = Vector2.new(0, 0)
	self.startPos = nil
	self.lastPos = nil
	self.panBeginLook = nil
	self.isRightMouseDown = false
	self.isMiddleMouseDown = false
	self.fingerTouches = {}
	self.dynamicTouchInput = nil
	self.numUnsunkTouches = 0
	self.startingDiff = nil
	self.pinchBeginZoom = nil

	if UserInputService.MouseBehavior ~= Enum.MouseBehavior.LockCenter then
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	end
end

function BaseCamera:ResetInputStates()
	self.isRightMouseDown = false
	self.isMiddleMouseDown = false
	self:OnMousePanButtonReleased()

	if UserInputService.TouchEnabled then
		for k in pairs(self.fingerTouches) do
			self.fingerTouches[k] = nil
		end

		self.dynamicTouchInput = nil
		self.panBeginLook = nil
		self.startPos = nil
		self.lastPos = nil
		self.userPanningTheCamera = false
		self.startingDiff = nil
		self.pinchBeginZoom = nil
		self.numUnsunkTouches = 0
	end
end

function BaseCamera:GetGamepadPan(_, p2, data)
	if data.UserInputType ~= self.activeGamepad or data.KeyCode ~= Enum.KeyCode.Thumbstick2 then
		return Enum.ContextActionResult.Pass
	end

	if p2 == Enum.UserInputState.Cancel then
		self.gamepadPanningCamera = vector4
		return
	end

	if Vector2.new(data.Position.X, -data.Position.Y).magnitude > 0.2 then
		self.gamepadPanningCamera = Vector2.new(data.Position.X, -data.Position.Y)
	else
		self.gamepadPanningCamera = vector4
	end

	return Enum.ContextActionResult.Sink
end

function BaseCamera:DoKeyboardPanTurn(_, p, p2)
	if not self.hasGameLoaded and VRService.VREnabled then
		return Enum.ContextActionResult.Pass
	end

	if p == Enum.UserInputState.Cancel then
		self.turningLeft = false
		self.turningRight = false
	else
		if self.panBeginLook ~= nil or not self.keyPanEnabled then
			return Enum.ContextActionResult.Pass
		end

		if p2.KeyCode == Enum.KeyCode.Left then
			self.turningLeft = p == Enum.UserInputState.Begin
		elseif p2.KeyCode == Enum.KeyCode.Right then
			self.turningRight = p == Enum.UserInputState.Begin
		end
	end

	return Enum.ContextActionResult.Sink
end

function BaseCamera:DoPanRotateCamera(p)
	local rotateVectorByAngleAndRound = CameraUtils.RotateVectorByAngleAndRound(
		self:GetCameraLookVector() * createVector(1, 0, 1),
		p,
		0.7853981633974483
	)

	if rotateVectorByAngleAndRound ~= 0 then
		self.rotateInput += Vector2.new(rotateVectorByAngleAndRound, 0)
		self.lastUserPanCamera = tick()
		self.lastCameraTransform = nil
	end
end

function BaseCamera:DoKeyboardPan(_, p, p2)
	if v4 or not self.hasGameLoaded and VRService.VREnabled or p ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end

	if self.panBeginLook ~= nil or not self.keyPanEnabled then
		return Enum.ContextActionResult.Pass
	end

	if p2.KeyCode == Enum.KeyCode.Comma then
		self:DoPanRotateCamera(-0.5890486225480862)
	elseif p2.KeyCode == Enum.KeyCode.Period then
		self:DoPanRotateCamera(0.5890486225480862)
	elseif p2.KeyCode == Enum.KeyCode.PageUp then
		self.rotateInput += Vector2.new(0, 0.2617993877991494)
		self.lastCameraTransform = nil
	elseif p2.KeyCode == Enum.KeyCode.PageDown then
		self.rotateInput += Vector2.new(0, -0.2617993877991494)
		self.lastCameraTransform = nil
	end

	return Enum.ContextActionResult.Sink
end

function BaseCamera:DoGamepadZoom(_, p, p2)
	if p2.UserInputType ~= self.activeGamepad then
		return Enum.ContextActionResult.Pass
	end

	if p2.KeyCode == Enum.KeyCode.ButtonR3 then
		if p == Enum.UserInputState.Begin and self.distanceChangeEnabled then
			local cameraToSubjectDistance = self:GetCameraToSubjectDistance()

			if v2 then
				if cameraToSubjectDistance > 15 then
					self:SetCameraToSubjectDistance(10)
				elseif cameraToSubjectDistance > 5 then
					self:SetCameraToSubjectDistance(0)
				else
					self:SetCameraToSubjectDistance(20)
				end
			elseif cameraToSubjectDistance > 0.5 then
				self:SetCameraToSubjectDistance(0)
			else
				self:SetCameraToSubjectDistance(10)
			end
		end
	elseif p2.KeyCode == Enum.KeyCode.DPadLeft then
		self.dpadLeftDown = p == Enum.UserInputState.Begin
	elseif p2.KeyCode == Enum.KeyCode.DPadRight then
		self.dpadRightDown = p == Enum.UserInputState.Begin
	end

	if self.dpadLeftDown then
		self.currentZoomSpeed = 1.04
	elseif self.dpadRightDown then
		self.currentZoomSpeed = 0.96
	else
		self.currentZoomSpeed = 1
	end

	return Enum.ContextActionResult.Sink
end

function BaseCamera:DoKeyboardZoom(_, p, p2)
	if not self.hasGameLoaded and VRService.VREnabled or p ~= Enum.UserInputState.Begin or (not self.distanceChangeEnabled or Players.LocalPlayer.CameraMode == Enum.CameraMode.LockFirstPerson) then
		return Enum.ContextActionResult.Pass
	end

	if p2.KeyCode == Enum.KeyCode.I then
		self:SetCameraToSubjectDistance(self.currentSubjectDistance - 5)
	elseif p2.KeyCode == Enum.KeyCode.O then
		self:SetCameraToSubjectDistance(self.currentSubjectDistance + 5)
	end

	return Enum.ContextActionResult.Sink
end

function BaseCamera:BindAction(p2, p3, p4, ...)
	table.insert(self.boundContextActions, p2)
	ContextActionService:BindActionAtPriority(p2, p3, p4, 0, ...)
end

function BaseCamera:BindGamepadInputActions()
	self:BindAction("BaseCameraGamepadPan", function(p, p2, p3)
		return self:GetGamepadPan(p, p2, p3)
	end, false, Enum.KeyCode.Thumbstick2)
	self:BindAction("BaseCameraGamepadZoom", function(p, p2, p3)
		return self:DoGamepadZoom(p, p2, p3)
	end, false, Enum.KeyCode.DPadLeft, Enum.KeyCode.DPadRight, Enum.KeyCode.ButtonR3)
end

function BaseCamera:BindKeyboardInputActions()
	self:BindAction("BaseCameraKeyboardPanArrowKeys", function(p, p2, p3)
		return self:DoKeyboardPanTurn(p, p2, p3)
	end, false, Enum.KeyCode.Left, Enum.KeyCode.Right)
	self:BindAction("BaseCameraKeyboardPan", function(p, p2, p3)
		return self:DoKeyboardPan(p, p2, p3)
	end, false, Enum.KeyCode.Comma, Enum.KeyCode.Period, Enum.KeyCode.PageUp, Enum.KeyCode.PageDown)
	self:BindAction("BaseCameraKeyboardZoom", function(p, p2, p3)
		return self:DoKeyboardZoom(p, p2, p3)
	end, false, Enum.KeyCode.I, Enum.KeyCode.O)
end

local function isInDynamicThumbstickArea(dynamicTouchInput)
	local playerGui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
	local touchGui = playerGui and playerGui:FindFirstChild("TouchGui")
	local touchControlFrame = touchGui and touchGui:FindFirstChild("TouchControlFrame")
	local dynamicThumbstickFrame = touchControlFrame and touchControlFrame:FindFirstChild("DynamicThumbstickFrame")

	if not dynamicThumbstickFrame then
		return false
	end

	local absolutePosition = dynamicThumbstickFrame.AbsolutePosition
	local v6 = absolutePosition + dynamicThumbstickFrame.AbsoluteSize
	return dynamicTouchInput.Position.X >= absolutePosition.X and dynamicTouchInput.Position.Y >= absolutePosition.Y and dynamicTouchInput.Position.X <= v6.X and dynamicTouchInput.Position.Y <= v6.Y
end

function BaseCamera:AdjustTouchSensitivity(p, p2)
	local cFrame = game.Workspace.CurrentCamera and game.Workspace.CurrentCamera.CFrame

	if not cFrame then
		return p2
	end

	local eulerAnglesYXZ = cFrame:ToEulerAnglesYXZ()
	local v6 = 2.1

	if eulerAnglesYXZ > 0.5235987755982988 and p.Y < 0 then
		v6 = 2.1 - (1 - (1 - (eulerAnglesYXZ - 0.5235987755982988) / 0.8726646259971648) ^ 3) * 1.6
	elseif eulerAnglesYXZ < -0.2617993877991494 and p.Y > 0 then
		v6 = 2.1 - (1 - (1 - (eulerAnglesYXZ - -0.2617993877991494) / -1.1344640137963142) ^ 3) * 1.6
	end

	return Vector2.new(p2.X, p2.Y * v6)
end

function BaseCamera:OnTouchBegan(dynamicTouchInput, p)
	if self.isDynamicThumbstickEnabled and not p then
		if self.dynamicTouchInput == nil and isInDynamicThumbstickArea(dynamicTouchInput) then
			self.dynamicTouchInput = dynamicTouchInput
			return
		end

		self.fingerTouches[dynamicTouchInput] = p
		self.inputStartPositions[dynamicTouchInput] = dynamicTouchInput.Position
		self.inputStartTimes[dynamicTouchInput] = tick()
		self.numUnsunkTouches += 1
	end
end

function BaseCamera:OnTouchChanged(p, p2)
	if self.fingerTouches[p] == nil then
		if self.isDynamicThumbstickEnabled then
			return
		end

		self.fingerTouches[p] = p2

		if not p2 then
			self.numUnsunkTouches += 1
		end
	end

	if self.numUnsunkTouches == 1 then
		if self.fingerTouches[p] == false then
			self.panBeginLook = self.panBeginLook or self:GetCameraLookVector()
			self.startPos = self.startPos or p.Position
			self.lastPos = self.lastPos or self.startPos
			self.userPanningTheCamera = true
			local v6 = p.Position - self.lastPos
			local vector7 = Vector2.new(v6.X, v6.Y * UserGameSettings:GetCameraYInvertValue())

			if self.panEnabled then
				if v then
					self:AdjustTouchSensitivity(vector7, vector5)
				end

				local inputTranslationToCameraAngleChange = self:InputTranslationToCameraAngleChange(vector7, vector5)
				self.rotateInput += inputTranslationToCameraAngleChange
			end

			self.lastPos = p.Position
		end
	else
		self.panBeginLook = nil
		self.startPos = nil
		self.lastPos = nil
		self.userPanningTheCamera = false
	end

	if self.numUnsunkTouches == 2 then
		local v6 = {}

		for k, fingerTouch in pairs(self.fingerTouches) do
			if not fingerTouch then
				table.insert(v6, k)
			end
		end

		if #v6 == 2 then
			local magnitude = (v6[1].Position - v6[2].Position).magnitude

			if self.startingDiff and self.pinchBeginZoom then
				local v7 = magnitude / math.max(0.01, self.startingDiff)
				local clamped = CameraUtils.Clamp(0.1, 10, v7)

				if self.distanceChangeEnabled then
					self:SetCameraToSubjectDistance(self.pinchBeginZoom / clamped)
				end
			else
				self.startingDiff = magnitude
				self.pinchBeginZoom = self:GetCameraToSubjectDistance()
			end
		end
	else
		self.startingDiff = nil
		self.pinchBeginZoom = nil
	end
end

function BaseCamera:OnTouchEnded(p, _)
	if p == self.dynamicTouchInput then
		self.dynamicTouchInput = nil
		return
	end

	if self.fingerTouches[p] == false then
		if self.numUnsunkTouches == 1 then
			self.panBeginLook = nil
			self.startPos = nil
			self.lastPos = nil
			self.userPanningTheCamera = false
		elseif self.numUnsunkTouches == 2 then
			self.startingDiff = nil
			self.pinchBeginZoom = nil
		end
	end

	if self.fingerTouches[p] ~= nil and self.fingerTouches[p] == false then
		self.numUnsunkTouches -= 1
	end

	self.fingerTouches[p] = nil
	self.inputStartPositions[p] = nil
	self.inputStartTimes[p] = nil
end

function BaseCamera:OnMouse2Down(p, p2)
	if p2 then
		return
	end

	self.isRightMouseDown = true
	self:OnMousePanButtonPressed(p, p2)
end

function BaseCamera:OnMouse2Up(p, p2)
	self.isRightMouseDown = false
	self:OnMousePanButtonReleased(p, p2)
end

function BaseCamera:OnMouse3Down(p, p2)
	if p2 then
		return
	end

	self.isMiddleMouseDown = true
	self:OnMousePanButtonPressed(p, p2)
end

function BaseCamera:OnMouse3Up(p, p2)
	self.isMiddleMouseDown = false
	self:OnMousePanButtonReleased(p, p2)
end

function BaseCamera:OnMouseMoved(p, _)
	if not self.hasGameLoaded and VRService.VREnabled then
		return
	end

	local delta = p.Delta
	local vector7 = Vector2.new(delta.X, delta.Y * UserGameSettings:GetCameraYInvertValue())

	if self.panEnabled and (self.startPos and self.lastPos and self.panBeginLook or self.inFirstPerson or self.inMouseLockedMode) then
		local inputTranslationToCameraAngleChange = self:InputTranslationToCameraAngleChange(vector7, vector6)
		self.rotateInput += inputTranslationToCameraAngleChange
	end

	if self.startPos and self.lastPos and self.panBeginLook then
		self.lastPos += p.Delta
	end
end

function BaseCamera:OnMousePanButtonPressed(p, p2)
	if p2 then
		return
	end

	self:UpdateMouseBehavior()
	self.panBeginLook = self.panBeginLook or self:GetCameraLookVector()
	self.startPos = self.startPos or p.Position
	self.lastPos = self.lastPos or self.startPos
	self.userPanningTheCamera = true
end

function BaseCamera:OnMousePanButtonReleased(_, _)
	self:UpdateMouseBehavior()

	if not (self.isRightMouseDown or self.isMiddleMouseDown) then
		self.panBeginLook = nil
		self.startPos = nil
		self.lastPos = nil
		self.userPanningTheCamera = false
	end
end

function BaseCamera:OnMouseWheel(p, p2)
	if not self.hasGameLoaded and VRService.VREnabled then
		return
	end

	if not p2 and self.distanceChangeEnabled then
		local v6 = -p.Position.Z
		self:SetCameraToSubjectDistance(self.inFirstPerson and v6 > 0 and 1 or self.currentSubjectDistance + 0.156 * self.currentSubjectDistance * v6 + 1.7 * v6)
	end
end

function BaseCamera:UpdateMouseBehavior()
	if self.inFirstPerson or self.inMouseLockedMode then
		UserGameSettings.RotationType = Enum.RotationType.CameraRelative
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	else
		UserGameSettings.RotationType = Enum.RotationType.MovementRelative

		if self.isRightMouseDown or self.isMiddleMouseDown then
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
		else
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		end
	end
end

function BaseCamera:UpdateForDistancePropertyChange()
	self:SetCameraToSubjectDistance(self.currentSubjectDistance)
end

function BaseCamera:SetCameraToSubjectDistance(p)
	local localPlayer = Players.LocalPlayer
	local currentSubjectDistance = self.currentSubjectDistance

	if localPlayer.CameraMode == Enum.CameraMode.LockFirstPerson then
		self.currentSubjectDistance = 0.5

		if not self.inFirstPerson then
			self:EnterFirstPerson()
		end
	else
		local clamped = CameraUtils.Clamp(localPlayer.CameraMinZoomDistance, localPlayer.CameraMaxZoomDistance, p)

		if clamped < 1 then
			self.currentSubjectDistance = 0.5

			if not self.inFirstPerson then
				self:EnterFirstPerson()
			end
		else
			self.currentSubjectDistance = clamped

			if self.inFirstPerson then
				self:LeaveFirstPerson()
			end
		end
	end

	ZoomController.SetZoomParameters(self.currentSubjectDistance, (math.sign(p - currentSubjectDistance)))
	return self.currentSubjectDistance
end

function BaseCamera:SetCameraType(cameraType)
	self.cameraType = cameraType
end

function BaseCamera.GetCameraType(p)
	return p.cameraType
end

function BaseCamera:SetCameraMovementMode(cameraMovementMode)
	self.cameraMovementMode = cameraMovementMode
end

function BaseCamera.GetCameraMovementMode(p)
	return p.cameraMovementMode
end

function BaseCamera:SetIsMouseLocked(inMouseLockedMode)
	self.inMouseLockedMode = inMouseLockedMode
	self:UpdateMouseBehavior()
end

function BaseCamera.GetIsMouseLocked(p)
	return p.inMouseLockedMode
end

function BaseCamera:SetMouseLockOffset(mouseLockOffset)
	self.mouseLockOffset = mouseLockOffset
end

function BaseCamera.GetMouseLockOffset(p)
	return p.mouseLockOffset
end

function BaseCamera.InFirstPerson(p)
	return p.inFirstPerson
end

function BaseCamera:EnterFirstPerson() end

function BaseCamera:LeaveFirstPerson() end

function BaseCamera:GetCameraToSubjectDistance()
	return self.currentSubjectDistance
end

function BaseCamera.GetMeasuredDistanceToFocus(_)
	local currentCamera = game.Workspace.CurrentCamera

	if currentCamera then
		return (currentCamera.CoordinateFrame.p - currentCamera.Focus.p).magnitude
	end

	return nil
end

function BaseCamera:GetCameraLookVector()
	return game.Workspace.CurrentCamera and game.Workspace.CurrentCamera.CFrame.lookVector or createVector(0, 0, 1)
end

function BaseCamera:CalculateNewLookCFrame(p)
	local v6 = p or self:GetCameraLookVector()
	local v7 = math.asin(v6.y)
	local clamped = CameraUtils.Clamp(v7 + -1.3962634015954636, v7 + 1.3962634015954636, self.rotateInput.y)
	local vector7 = Vector2.new(self.rotateInput.x, clamped)
	local cframe = CFrame.new(createVector(0, 0, 0), v6)
	return CFrame.Angles(0, -vector7.x, 0) * cframe * CFrame.Angles(-vector7.y, 0, 0)
end

function BaseCamera:CalculateNewLookVector(p)
	return self:CalculateNewLookCFrame(p).lookVector
end

function BaseCamera:CalculateNewLookVectorVR()
	local unit = ((self:GetSubjectPosition() - game.Workspace.CurrentCamera.CFrame.p) * createVector(1, 0, 1)).unit
	local vector7 = Vector2.new(self.rotateInput.x, 0)
	local cframe = CFrame.new(createVector(0, 0, 0), unit)
	return ((CFrame.Angles(0, -vector7.x, 0) * cframe * CFrame.Angles(-vector7.y, 0, 0)).lookVector * createVector(
		1,
		0,
		1
	)).unit
end

function BaseCamera.GetHumanoid(p)
	local localPlayer = Players.LocalPlayer
	local character = localPlayer and localPlayer.Character

	if not character then
		return nil
	end

	local v6 = p.humanoidCache[localPlayer]

	if v6 and v6.Parent == character then
		return v6
	end

	p.humanoidCache[localPlayer] = nil
	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		p.humanoidCache[localPlayer] = humanoid
	end

	return humanoid
end

function BaseCamera.GetHumanoidPartToFollow(_, p, p2)
	if p2 ~= Enum.HumanoidStateType.Dead then
		return p.Torso
	end

	local parent = p.Parent

	if parent then
		return parent:FindFirstChild("Head") or p.Torso
	end

	return p.Torso
end

function BaseCamera:UpdateGamepad()
	local gamepadPanningCamera = self.gamepadPanningCamera

	if not gamepadPanningCamera or not self.hasGameLoaded and VRService.VREnabled then
		return vector4
	end

	local gamepadLinearToCurve = CameraUtils.GamepadLinearToCurve(gamepadPanningCamera)
	local now = tick()

	if gamepadLinearToCurve.X == 0 and gamepadLinearToCurve.Y == 0 then
		if gamepadLinearToCurve == vector4 then
			self.lastThumbstickRotate = nil

			if self.lastThumbstickPos == vector4 then
				self.currentSpeed = 0
			end
		end
	else
		self.userPanningTheCamera = true
	end

	local v6

	if self.lastThumbstickRotate then
		if VRService.VREnabled then
			self.currentSpeed = self.vrMaxSpeed
		else
			local v7 = (now - self.lastThumbstickRotate) * 10
			self.currentSpeed += self.maxSpeed * (v7 * v7 / self.numOfSeconds)

			if self.currentSpeed > self.maxSpeed then
				self.currentSpeed = self.maxSpeed
			end

			if self.lastVelocity then
				local magnitude = ((gamepadLinearToCurve - self.lastThumbstickPos) / (now - self.lastThumbstickRotate) - self.lastVelocity).magnitude

				if magnitude > 12 then
					self.currentSpeed *= 20 / magnitude

					if self.currentSpeed > self.maxSpeed then
						self.currentSpeed = self.maxSpeed
					end
				end
			end
		end

		v6 = UserGameSettings.GamepadCameraSensitivity * self.currentSpeed
		self.lastVelocity = (gamepadLinearToCurve - self.lastThumbstickPos) / (now - self.lastThumbstickRotate)
	else
		v6 = 0
	end

	self.lastThumbstickPos = gamepadLinearToCurve
	self.lastThumbstickRotate = now
	return Vector2.new(
		gamepadLinearToCurve.X * v6,
		gamepadLinearToCurve.Y * v6 * self.ySensitivity * UserGameSettings:GetCameraYInvertValue()
	)
end

function BaseCamera.ApplyVRTransform(p)
	if not VRService.VREnabled then
		return
	end

	local rootJoint = p.humanoidRootPart and p.humanoidRootPart:FindFirstChild("RootJoint")

	if not rootJoint then
		return
	end

	local cameraSubject = game.Workspace.CurrentCamera.CameraSubject
	local v6 = cameraSubject and cameraSubject:IsA("VehicleSeat")

	if not p.inFirstPerson or v6 then
		rootJoint.C0 = CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0)
		return
	end

	local userCFrame = VRService:GetUserCFrame(Enum.UserCFrame.Head)
	local v7 = userCFrame - userCFrame.p
	rootJoint.C0 = CFrame.new(v7:vectorToObjectSpace(userCFrame.p)) * CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0)
end

function BaseCamera.IsInFirstPerson(p)
	return p.inFirstPerson
end

function BaseCamera:ShouldUseVRRotation()
	if not VRService.VREnabled or not self.VRRotationIntensityAvailable and tick() - self.lastVRRotationIntensityCheckTime < 1 then
		return false
	end

	local success6, result6 = pcall(function()
		return StarterGui:GetCore("VRRotationIntensity")
	end)
	self.VRRotationIntensityAvailable = success6 and result6 ~= nil
	self.lastVRRotationIntensityCheckTime = tick()

	if success6 then
		if result6 == nil then
			success6 = false
		else
			success6 = result6 ~= "Smooth"
		end
	end

	self.shouldUseVRRotation = success6
	return self.shouldUseVRRotation
end

function BaseCamera:GetVRRotationInput()
	local v6 = vector4
	local success6, result6 = pcall(function()
		return StarterGui:GetCore("VRRotationIntensity")
	end)

	if not success6 then
		return
	end

	local gamepadPanningCamera = self.GamepadPanningCamera or vector4
	local v7 = tick() - self.lastVRRotationTime >= self:GetRepeatDelayValue(result6)

	if math.abs(gamepadPanningCamera.x) >= self:GetActivateValue() then
		if v7 or not self.vrRotateKeyCooldown[Enum.KeyCode.Thumbstick2] then
			local v8 = gamepadPanningCamera.x < 0 and -1 or 1
			v6 += self:GetRotateAmountValue(result6) * v8
			self.vrRotateKeyCooldown[Enum.KeyCode.Thumbstick2] = true
		end
	elseif math.abs(gamepadPanningCamera.x) < self:GetActivateValue() - 0.1 then
		self.vrRotateKeyCooldown[Enum.KeyCode.Thumbstick2] = nil
	end

	if self.turningLeft then
		if v7 or not self.vrRotateKeyCooldown[Enum.KeyCode.Left] then
			v6 -= self:GetRotateAmountValue(result6)
			self.vrRotateKeyCooldown[Enum.KeyCode.Left] = true
		end
	else
		self.vrRotateKeyCooldown[Enum.KeyCode.Left] = nil
	end

	if self.turningRight then
		if v7 or not self.vrRotateKeyCooldown[Enum.KeyCode.Right] then
			v6 += self:GetRotateAmountValue(result6)
			self.vrRotateKeyCooldown[Enum.KeyCode.Right] = true
		end
	else
		self.vrRotateKeyCooldown[Enum.KeyCode.Right] = nil
	end

	if v6 ~= vector4 then
		self.lastVRRotationTime = tick()
	end

	return v6
end

function BaseCamera:CancelCameraFreeze(p)
	if not p then
		self.cameraTranslationConstraints = Vector3.new(
			self.cameraTranslationConstraints.x,
			1,
			self.cameraTranslationConstraints.z
		)
	end

	if self.cameraFrozen then
		self.trackingHumanoid = nil
		self.cameraFrozen = false
	end
end

function BaseCamera:StartCameraFreeze(humanoidJumpOrigin, trackingHumanoid)
	if not self.cameraFrozen then
		self.humanoidJumpOrigin = humanoidJumpOrigin
		self.trackingHumanoid = trackingHumanoid
		self.cameraTranslationConstraints = Vector3.new(
			self.cameraTranslationConstraints.x,
			0,
			self.cameraTranslationConstraints.z
		)
		self.cameraFrozen = true
	end
end

function BaseCamera:OnNewCameraSubject()
	if self.subjectStateChangedConn then
		self.subjectStateChangedConn:Disconnect()
		self.subjectStateChangedConn = nil
	end

	local cameraSubject = workspace.CurrentCamera and workspace.CurrentCamera.CameraSubject

	if self.trackingHumanoid ~= cameraSubject then
		self:CancelCameraFreeze()
	end

	if cameraSubject and cameraSubject:IsA("Humanoid") then
		self.subjectStateChangedConn = cameraSubject.StateChanged:Connect(function(_, p)
			if VRService.VREnabled and p == Enum.HumanoidStateType.Jumping and not self.inFirstPerson then
				self:StartCameraFreeze(self:GetSubjectPosition(), cameraSubject)
			elseif p ~= Enum.HumanoidStateType.Jumping and p ~= Enum.HumanoidStateType.Freefall then
				self:CancelCameraFreeze(true)
			end
		end)
	end
end

function BaseCamera:GetVRFocus(data, p)
	local lastCameraFocus = self.LastCameraFocus or data

	if not self.cameraFrozen then
		self.cameraTranslationConstraints = Vector3.new(
			self.cameraTranslationConstraints.x,
			math.min(1, self.cameraTranslationConstraints.y + 0.42 * p),
			self.cameraTranslationConstraints.z
		)
	end

	local cframe

	if self.cameraFrozen and self.humanoidJumpOrigin and self.humanoidJumpOrigin.y > lastCameraFocus.y then
		cframe = CFrame.new((Vector3.new(data.x, math.min(self.humanoidJumpOrigin.y, lastCameraFocus.y + 5 * p), data.z)))
	else
		cframe = CFrame.new(Vector3.new(data.x, lastCameraFocus.y, data.z):lerp(
			data,
			self.cameraTranslationConstraints.y
		))
	end

	if not self.cameraFrozen then
		return cframe
	end

	if self.inFirstPerson then
		self:CancelCameraFreeze()
	end

	if self.humanoidJumpOrigin and data.y < self.humanoidJumpOrigin.y - 0.5 then
		self:CancelCameraFreeze()
	end

	return cframe
end

function BaseCamera:GetRotateAmountValue(p)
	local v6 = p or StarterGui:GetCore("VRRotationIntensity")

	if not v6 then
		return vector4
	end

	if v6 == "Low" then
		return vector2
	elseif v6 == "High" then
		return vector3
	end

	return vector4
end

function BaseCamera:GetRepeatDelayValue(p)
	local v6 = p or StarterGui:GetCore("VRRotationIntensity")

	if not v6 then
		return 0
	end

	if v6 == "Low" then
		return 0.1
	elseif v6 == "High" then
		return 0.4
	end

	return 0
end

function BaseCamera.Test(_)
	print("BaseCamera:Test()")
end

function BaseCamera.Update(_, _)
	warn("BaseCamera:Update() This is a virtual function that should never be getting called.")
	return game.Workspace.CurrentCamera.CFrame, game.Workspace.CurrentCamera.Focus
end

return BaseCamera