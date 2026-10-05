local createVector = vector.create
Vector2.new(0.2617993877991494, 0)
Vector2.new(0.7853981633974483, 0)
Vector2.new(0, 0)
local CameraUtils = require(script.Parent:WaitForChild("CameraUtils"))
local ZoomController = require(script.Parent:WaitForChild("ZoomController"))
local CameraToggleStateController = require(script.Parent:WaitForChild("CameraToggleStateController"))
local CameraInput = require(script.Parent:WaitForChild("CameraInput"))
local CameraUI = require(script.Parent:WaitForChild("CameraUI"))
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
game:GetService("StarterGui")
local VRService = game:GetService("VRService")
local UserGameSettings = UserSettings():GetService("UserGameSettings")
local localPlayer = Players.LocalPlayer
local BaseCamera = {}
BaseCamera.__index = BaseCamera

function BaseCamera.new()
	local object = setmetatable({}, BaseCamera)
	object.FIRST_PERSON_DISTANCE_THRESHOLD = 1
	object.cameraType = nil
	object.cameraMovementMode = nil
	object.lastCameraTransform = nil
	object.lastUserPanCamera = tick()
	object.humanoidRootPart = nil
	object.humanoidCache = {}
	object.lastSubject = nil
	object.lastSubjectPosition = createVector(0, 5, 0)
	object.lastSubjectCFrame = CFrame.new(object.lastSubjectPosition)
	object.defaultSubjectDistance = math.clamp(
		12.5,
		localPlayer.CameraMinZoomDistance,
		localPlayer.CameraMaxZoomDistance
	)
	object.currentSubjectDistance = math.clamp(
		12.5,
		localPlayer.CameraMinZoomDistance,
		localPlayer.CameraMaxZoomDistance
	)
	object.inFirstPerson = false
	object.inMouseLockedMode = false
	object.portraitMode = false
	object.isSmallTouchScreen = false
	object.resetCameraAngle = true
	object.enabled = false
	object.PlayerGui = nil
	object.cameraChangedConn = nil
	object.viewportSizeChangedConn = nil
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
	object.gamepadZoomPressConnection = nil
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

	object:OnPlayerCameraPropertyChange()
	return object
end

function BaseCamera.GetModuleName(_)
	return "BaseCamera"
end

function BaseCamera:OnCharacterAdded(instance)
	self.resetCameraAngle = self.resetCameraAngle or self:GetEnabled()
	self.humanoidRootPart = nil

	if UserInputService.TouchEnabled then
		self.PlayerGui = localPlayer:WaitForChild("PlayerGui")

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
	local humanoid = (not self.humanoidRootPart and localPlayer.Character and true or false) and localPlayer.Character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		self.humanoidRootPart = humanoid.RootPart
	end

	return self.humanoidRootPart
end

function BaseCamera.GetBodyPartToFollow(_, object, _: boolean)
	if object:GetState() == Enum.HumanoidStateType.Dead then
		local parent = object.Parent

		if parent and parent:IsA("Model") then
			return parent:FindFirstChild("Head") or object.RootPart
		end
	end

	return object.RootPart
end

function BaseCamera:GetSubjectCFrame()
	local lastSubjectCFrame = self.lastSubjectCFrame
	local currentCamera = workspace.CurrentCamera
	local cameraSubject = currentCamera and currentCamera.CameraSubject

	if not cameraSubject then
		return lastSubjectCFrame
	end

	if cameraSubject:IsA("Humanoid") then
		local v = cameraSubject:GetState() == Enum.HumanoidStateType.Dead
		local rootPart = cameraSubject.RootPart

		if v and cameraSubject.Parent and cameraSubject.Parent:IsA("Model") then
			rootPart = cameraSubject.Parent:FindFirstChild("Head") or rootPart
		end

		if rootPart and rootPart:IsA("BasePart") then
			local v2

			if cameraSubject.RigType == Enum.HumanoidRigType.R15 then
				if cameraSubject.AutomaticScalingEnabled then
					v2 = createVector(0, 1.5, 0)
					local rootPart2 = cameraSubject.RootPart

					if rootPart == rootPart2 then
						v2 += Vector3.new(0, (rootPart2.Size.Y - 2) / 2, 0)
					end
				else
					v2 = createVector(0, 2, 0)
				end
			else
				v2 = createVector(0, 1.5, 0)
			end

			lastSubjectCFrame = rootPart.CFrame * CFrame.new((v and createVector(0, 0, 0) or v2) + cameraSubject.CameraOffset)
		end
	elseif cameraSubject:IsA("BasePart") then
		lastSubjectCFrame = cameraSubject.CFrame
	elseif cameraSubject:IsA("Model") then
		if cameraSubject.PrimaryPart then
			lastSubjectCFrame = cameraSubject:GetPrimaryPartCFrame()
		else
			lastSubjectCFrame = CFrame.new()
		end
	end

	if lastSubjectCFrame then
		self.lastSubjectCFrame = lastSubjectCFrame
	end

	return lastSubjectCFrame
end

function BaseCamera.GetSubjectVelocity(_)
	local currentCamera = workspace.CurrentCamera
	local cameraSubject = currentCamera and currentCamera.CameraSubject

	if not cameraSubject then
		return createVector(0, 0, 0)
	end

	if cameraSubject:IsA("BasePart") then
		return cameraSubject.Velocity
	end

	if cameraSubject:IsA("Humanoid") then
		local rootPart = cameraSubject.RootPart

		if rootPart then
			return rootPart.Velocity
		end
	else
		local primaryPart = cameraSubject:IsA("Model") and cameraSubject.PrimaryPart

		if primaryPart then
			return primaryPart.Velocity
		end
	end

	return createVector(0, 0, 0)
end

function BaseCamera.GetSubjectRotVelocity(_)
	local currentCamera = workspace.CurrentCamera
	local cameraSubject = currentCamera and currentCamera.CameraSubject

	if not cameraSubject then
		return createVector(0, 0, 0)
	end

	if cameraSubject:IsA("BasePart") then
		return cameraSubject.RotVelocity
	end

	if cameraSubject:IsA("Humanoid") then
		local rootPart = cameraSubject.RootPart

		if rootPart then
			return rootPart.RotVelocity
		end
	else
		local primaryPart = cameraSubject:IsA("Model") and cameraSubject.PrimaryPart

		if primaryPart then
			return primaryPart.RotVelocity
		end
	end

	return createVector(0, 0, 0)
end

function BaseCamera:StepZoom()
	local currentSubjectDistance = self.currentSubjectDistance
	local zoomDelta = CameraInput.getZoomDelta()

	if math.abs(zoomDelta) > 0 then
		local v

		if zoomDelta > 0 then
			v = math.max(
				currentSubjectDistance + zoomDelta * (currentSubjectDistance * 0.5 + 1),
				self.FIRST_PERSON_DISTANCE_THRESHOLD
			)
		else
			v = math.max((currentSubjectDistance + zoomDelta) / (1 - zoomDelta * 0.5), 0.5)
		end

		self:SetCameraToSubjectDistance(v < self.FIRST_PERSON_DISTANCE_THRESHOLD and 0.5 or v)
	end

	return ZoomController.GetZoomRadius()
end

function BaseCamera:GetSubjectPosition()
	local lastSubjectPosition = self.lastSubjectPosition
	local currentCamera = game.Workspace.CurrentCamera
	local cameraSubject = currentCamera and currentCamera.CameraSubject

	if not cameraSubject then
		return nil
	end

	if cameraSubject:IsA("Humanoid") then
		local v = cameraSubject:GetState() == Enum.HumanoidStateType.Dead
		local rootPart = cameraSubject.RootPart

		if v and cameraSubject.Parent and cameraSubject.Parent:IsA("Model") then
			rootPart = cameraSubject.Parent:FindFirstChild("Head") or rootPart
		end

		if rootPart and rootPart:IsA("BasePart") then
			local v2

			if cameraSubject.RigType == Enum.HumanoidRigType.R15 then
				if cameraSubject.AutomaticScalingEnabled then
					v2 = createVector(0, 1.5, 0)

					if rootPart == cameraSubject.RootPart then
						v2 += Vector3.new(0, cameraSubject.RootPart.Size.Y / 2 - 1, 0)
					end
				else
					v2 = createVector(0, 2, 0)
				end
			else
				v2 = createVector(0, 1.5, 0)
			end

			lastSubjectPosition = rootPart.CFrame.p + rootPart.CFrame:vectorToWorldSpace((v and createVector(0, 0, 0) or v2) + cameraSubject.CameraOffset)
		end
	elseif cameraSubject:IsA("VehicleSeat") then
		lastSubjectPosition = cameraSubject.CFrame.p + cameraSubject.CFrame:vectorToWorldSpace(createVector(0, 5, 0))
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
	if self.portraitMode then
		self.defaultSubjectDistance = math.clamp(
			25,
			localPlayer.CameraMinZoomDistance,
			localPlayer.CameraMaxZoomDistance
		)
	else
		self.defaultSubjectDistance = math.clamp(
			12.5,
			localPlayer.CameraMinZoomDistance,
			localPlayer.CameraMaxZoomDistance
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
	if localPlayer.DevTouchMovementMode == Enum.DevTouchMovementMode.UserChoice then
		if UserGameSettings.TouchMovementMode == Enum.TouchMovementMode.DynamicThumbstick or UserGameSettings.TouchMovementMode == Enum.TouchMovementMode.Default then
			self:OnDynamicThumbstickEnabled()
		else
			self:OnDynamicThumbstickDisabled()
		end
	end
end

function BaseCamera:OnDevTouchMovementModeChanged()
	if localPlayer.DevTouchMovementMode == Enum.DevTouchMovementMode.DynamicThumbstick then
		self:OnDynamicThumbstickEnabled()
	else
		self:OnGameSettingsTouchMovementModeChanged()
	end
end

function BaseCamera:OnPlayerCameraPropertyChange()
	self:SetCameraToSubjectDistance(self.currentSubjectDistance)
end

function BaseCamera.InputTranslationToCameraAngleChange(_, p, p2)
	return p * p2
end

function BaseCamera:GamepadZoomPress()
	local cameraToSubjectDistance = self:GetCameraToSubjectDistance()

	if cameraToSubjectDistance > 15 then
		self:SetCameraToSubjectDistance(10)
	elseif cameraToSubjectDistance > 5 then
		self:SetCameraToSubjectDistance(0)
	else
		self:SetCameraToSubjectDistance(20)
	end
end

function BaseCamera:Enable(enabled: boolean)
	if self.enabled ~= enabled then
		self.enabled = enabled

		if self.enabled then
			CameraInput.setInputEnabled(true)
			self.gamepadZoomPressConnection = CameraInput.gamepadZoomPress:Connect(function()
				self:GamepadZoomPress()
			end)

			if localPlayer.CameraMode == Enum.CameraMode.LockFirstPerson then
				self.currentSubjectDistance = 0.5

				if not self.inFirstPerson then
					self:EnterFirstPerson()
				end
			end
		else
			CameraInput.setInputEnabled(false)

			if self.gamepadZoomPressConnection then
				self.gamepadZoomPressConnection:Disconnect()
				self.gamepadZoomPressConnection = nil
			end

			self:Cleanup()
		end

		self:OnEnable(enabled)
	end
end

function BaseCamera:OnEnable(_: boolean) end

function BaseCamera:GetEnabled()
	return self.enabled
end

function BaseCamera:Cleanup()
	if self.subjectStateChangedConn then
		self.subjectStateChangedConn:Disconnect()
		self.subjectStateChangedConn = nil
	end

	if self.viewportSizeChangedConn then
		self.viewportSizeChangedConn:Disconnect()
		self.viewportSizeChangedConn = nil
	end

	self.lastCameraTransform = nil
	self.lastSubjectCFrame = nil
	CameraUtils.restoreMouseBehavior()
end

function BaseCamera.UpdateMouseBehavior(data)
	local v = UserGameSettings.ComputerMovementMode == Enum.ComputerMovementMode.ClickToMove

	if data.isCameraToggle and v == false then
		CameraUI.setCameraModeToastEnabled(true)
		CameraInput.enableCameraToggleInput()
		CameraToggleStateController(data.inFirstPerson)
	else
		CameraUI.setCameraModeToastEnabled(false)
		CameraInput.disableCameraToggleInput()

		if data.inFirstPerson or data.inMouseLockedMode then
			CameraUtils.setRotationTypeOverride(Enum.RotationType.CameraRelative)
			CameraUtils.setMouseBehaviorOverride(Enum.MouseBehavior.LockCenter)
		else
			CameraUtils.restoreRotationType()
			CameraUtils.restoreMouseBehavior()
		end
	end
end

function BaseCamera:UpdateForDistancePropertyChange()
	self:SetCameraToSubjectDistance(self.currentSubjectDistance)
end

function BaseCamera:SetCameraToSubjectDistance(value: number)
	local currentSubjectDistance = self.currentSubjectDistance

	if localPlayer.CameraMode == Enum.CameraMode.LockFirstPerson then
		self.currentSubjectDistance = 0.5

		if not self.inFirstPerson then
			self:EnterFirstPerson()
		end
	else
		local currentSubjectDistance2 = math.clamp(
			value,
			localPlayer.CameraMinZoomDistance,
			localPlayer.CameraMaxZoomDistance
		)

		if currentSubjectDistance2 < 1 then
			self.currentSubjectDistance = 0.5

			if not self.inFirstPerson then
				self:EnterFirstPerson()
			end
		else
			self.currentSubjectDistance = currentSubjectDistance2

			if self.inFirstPerson then
				self:LeaveFirstPerson()
			end
		end
	end

	ZoomController.SetZoomParameters(self.currentSubjectDistance, (math.sign(value - currentSubjectDistance)))
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

function BaseCamera:SetIsMouseLocked(inMouseLockedMode: boolean)
	self.inMouseLockedMode = inMouseLockedMode
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
	return game.Workspace.CurrentCamera and game.Workspace.CurrentCamera.CFrame.LookVector or createVector(0, 0, 1)
end

function BaseCamera:CalculateNewLookCFrameFromArg(vector2: Vector3?, point: Vector2)
	local v = vector2 or self:GetCameraLookVector()
	local v2 = math.asin((math.clamp(v.Y, -1, 1)))
	local v3 = math.clamp(point.Y, v2 + -1.3962634015954636, v2 + 1.3962634015954636)
	local vector3 = Vector2.new(point.X, v3)
	local cframe = CFrame.new(createVector(0, 0, 0), v)
	return CFrame.Angles(0, -vector3.X, 0) * cframe * CFrame.Angles(-vector3.Y, 0, 0)
end

function BaseCamera:CalculateNewLookVectorFromArg(vector2: Vector3?, point: Vector2)
	return self:CalculateNewLookCFrameFromArg(vector2, point).LookVector
end

function BaseCamera:CalculateNewLookVectorVRFromArg(point: Vector2)
	local unit = ((self:GetSubjectPosition() - game.Workspace.CurrentCamera.CFrame.p) * createVector(1, 0, 1)).unit
	local vector2 = Vector2.new(point.X, 0)
	local cframe = CFrame.new(createVector(0, 0, 0), unit)
	return ((CFrame.Angles(0, -vector2.X, 0) * cframe * CFrame.Angles(-vector2.Y, 0, 0)).LookVector * createVector(
		1,
		0,
		1
	)).unit
end

function BaseCamera.GetHumanoid(p)
	local character = localPlayer and localPlayer.Character

	if not character then
		return nil
	end

	local v = p.humanoidCache[localPlayer]

	if v and v.Parent == character then
		return v
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

function BaseCamera:OnNewCameraSubject()
	if self.subjectStateChangedConn then
		self.subjectStateChangedConn:Disconnect()
		self.subjectStateChangedConn = nil
	end
end

function BaseCamera.IsInFirstPerson(p)
	return p.inFirstPerson
end

function BaseCamera.Update(_, _)
	error("BaseCamera:Update() This is a virtual function that should never be getting called.", 2)
end

function BaseCamera.GetCameraHeight(p)
	if VRService.VREnabled and not p.inFirstPerson then
		return 0.25881904510252074 * p.currentSubjectDistance
	end

	return 0
end

return BaseCamera