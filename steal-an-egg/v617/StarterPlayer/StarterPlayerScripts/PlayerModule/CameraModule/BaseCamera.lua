local createVector = vector.create
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VRService = game:GetService("VRService")
local UserGameSettings = UserSettings():GetService("UserGameSettings")
local commonUtils = script.Parent.Parent:WaitForChild("CommonUtils")
local ConnectionUtil = require(commonUtils:WaitForChild("ConnectionUtil"))
local FlagUtil = require(commonUtils:WaitForChild("FlagUtil"))
local CameraUtils = require(script.Parent:WaitForChild("CameraUtils"))
local ZoomController = require(script.Parent:WaitForChild("ZoomController"))
local CameraToggleStateController = require(script.Parent:WaitForChild("CameraToggleStateController"))
local CameraInput = require(script.Parent:WaitForChild("CameraInput"))
local CameraUI = require(script.Parent:WaitForChild("CameraUI"))
local localPlayer = Players.LocalPlayer
local success, result = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserFixGamepadMaxZoom")
end)
local v = success and result
local userFlag = FlagUtil.getUserFlag("UserPSRemoveTouchEnabled")
Vector2.new(0, 0)
local _ = {
	CHARACTER_ADDED = "CHARACTER_ADDED",
	CAMERA_MODE_CHANGED = "CAMERA_MODE_CHANGED",
	CAMERA_MIN_DISTANCE_CHANGED = "CAMERA_MIN_DISTANCE_CHANGED",
	CAMERA_MAX_DISTANCE_CHANGED = "CAMERA_MAX_DISTANCE_CHANGED"
}
local BaseCamera = {}
BaseCamera.__index = BaseCamera

function BaseCamera.new()
	local self = setmetatable({}, BaseCamera)
	self._connections = ConnectionUtil.new()
	self.gamepadZoomLevels = { 0, 10, 20 }
	self.FIRST_PERSON_DISTANCE_THRESHOLD = 1
	self.cameraType = nil
	self.cameraMovementMode = nil
	self.lastCameraTransform = nil
	self.lastUserPanCamera = tick()
	self.humanoidRootPart = nil
	self.humanoidCache = {}
	self.lastSubject = nil
	self.lastSubjectPosition = createVector(0, 5, 0)
	self.lastSubjectCFrame = CFrame.new(self.lastSubjectPosition)
	self.currentSubjectDistance = math.clamp(12.5, localPlayer.CameraMinZoomDistance, localPlayer.CameraMaxZoomDistance)
	self.inFirstPerson = false
	self.inMouseLockedMode = false

	if not userFlag then
		self.portraitMode = false
		self.isSmallTouchScreen = false
	end

	self.resetCameraAngle = true
	self.enabled = false
	self.cameraChangedConn = nil

	if not userFlag then
		self.viewportSizeChangedConn = nil
	end

	self.shouldUseVRRotation = false
	self.VRRotationIntensityAvailable = false
	self.lastVRRotationIntensityCheckTime = 0
	self.lastVRRotationTime = 0
	self.vrRotateKeyCooldown = {}
	self.cameraTranslationConstraints = createVector(1, 1, 1)
	self.humanoidJumpOrigin = nil
	self.trackingHumanoid = nil
	self.cameraFrozen = false
	self.subjectStateChangedConn = nil
	self.gamepadZoomPressConnection = nil
	self.mouseLockOffset = createVector(0, 0, 0)
	UserGameSettings:SetCameraYInvertVisible()
	UserGameSettings:SetGamepadCameraSensitivityVisible()
	return self
end

function BaseCamera.GetModuleName(_)
	return "BaseCamera"
end

function BaseCamera:_setUpConfigurations()
	self._connections:trackConnection("CHARACTER_ADDED", localPlayer.CharacterAdded:Connect(function(character)
		self:OnCharacterAdded(character)
	end))
	self.humanoidRootPart = nil
	self._connections:trackConnection(
		"CAMERA_MODE_CHANGED",
		localPlayer:GetPropertyChangedSignal("CameraMode"):Connect(function()
			self:OnPlayerCameraPropertyChange()
		end)
	)
	self._connections:trackConnection(
		"CAMERA_MIN_DISTANCE_CHANGED",
		localPlayer:GetPropertyChangedSignal("CameraMinZoomDistance"):Connect(function()
			self:OnPlayerCameraPropertyChange()
		end)
	)
	self._connections:trackConnection(
		"CAMERA_MAX_DISTANCE_CHANGED",
		localPlayer:GetPropertyChangedSignal("CameraMaxZoomDistance"):Connect(function()
			self:OnPlayerCameraPropertyChange()
		end)
	)
	self:OnPlayerCameraPropertyChange()
end

function BaseCamera:OnCharacterAdded(_)
	self.resetCameraAngle = self.resetCameraAngle or self:GetEnabled()
	self.humanoidRootPart = nil
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
		local v2 = cameraSubject:GetState() == Enum.HumanoidStateType.Dead
		local cameraOffset = cameraSubject.CameraOffset

		if self:GetIsMouseLocked() then
			cameraOffset = Vector3.new()
		end

		local rootPart = cameraSubject.RootPart

		if v2 and cameraSubject.Parent and cameraSubject.Parent:IsA("Model") then
			rootPart = cameraSubject.Parent:FindFirstChild("Head") or rootPart
		end

		if rootPart and rootPart:IsA("BasePart") then
			local v3

			if cameraSubject.RigType == Enum.HumanoidRigType.R15 then
				if cameraSubject.AutomaticScalingEnabled then
					v3 = createVector(0, 1.5, 0)
					local rootPart2 = cameraSubject.RootPart

					if rootPart == rootPart2 then
						v3 += Vector3.new(0, (rootPart2.Size.Y - 2) / 2, 0)
					end
				else
					v3 = createVector(0, 2, 0)
				end
			else
				v3 = createVector(0, 1.5, 0)
			end

			lastSubjectCFrame = rootPart.CFrame * CFrame.new((v2 and createVector(0, 0, 0) or v3) + cameraOffset)
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
		local v2

		if zoomDelta > 0 then
			v2 = math.max(
				currentSubjectDistance + zoomDelta * (currentSubjectDistance * 0.5 + 1),
				self.FIRST_PERSON_DISTANCE_THRESHOLD
			)
		else
			v2 = math.max((currentSubjectDistance + zoomDelta) / (1 - zoomDelta * 0.5), 0.5)
		end

		self:SetCameraToSubjectDistance(v2 < self.FIRST_PERSON_DISTANCE_THRESHOLD and 0.5 or v2)
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
		local v2 = cameraSubject:GetState() == Enum.HumanoidStateType.Dead
		local cameraOffset = cameraSubject.CameraOffset

		if self:GetIsMouseLocked() then
			cameraOffset = Vector3.new()
		end

		local rootPart = cameraSubject.RootPart

		if v2 and cameraSubject.Parent and cameraSubject.Parent:IsA("Model") then
			rootPart = cameraSubject.Parent:FindFirstChild("Head") or rootPart
		end

		if rootPart and rootPart:IsA("BasePart") then
			local v3

			if cameraSubject.RigType == Enum.HumanoidRigType.R15 then
				if cameraSubject.AutomaticScalingEnabled then
					v3 = createVector(0, 1.5, 0)

					if rootPart == cameraSubject.RootPart then
						v3 += Vector3.new(0, cameraSubject.RootPart.Size.Y / 2 - 1, 0)
					end
				else
					v3 = createVector(0, 2, 0)
				end
			else
				v3 = createVector(0, 1.5, 0)
			end

			lastSubjectPosition = rootPart.CFrame.p + rootPart.CFrame:vectorToWorldSpace((v2 and createVector(0, 0, 0) or v3) + cameraOffset)
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

if not userFlag then
	function BaseCamera:OnViewportSizeChanged()
		local viewportSize = game.Workspace.CurrentCamera.ViewportSize
		self.portraitMode = viewportSize.X < viewportSize.Y
		self.isSmallTouchScreen = UserInputService.TouchEnabled and (viewportSize.Y < 500 or viewportSize.X < 700)
	end
end

function BaseCamera:OnCurrentCameraChanged()
	if not userFlag and UserInputService.TouchEnabled then
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

function BaseCamera:OnPlayerCameraPropertyChange()
	self:SetCameraToSubjectDistance(self.currentSubjectDistance)
end

function BaseCamera.InputTranslationToCameraAngleChange(_, p, p2)
	return p * p2
end

function BaseCamera:GamepadZoomPress()
	local cameraToSubjectDistance = self:GetCameraToSubjectDistance()
	local cameraMaxZoomDistance = localPlayer.CameraMaxZoomDistance

	for i = #self.gamepadZoomLevels, 1, -1 do
		local cameraMinZoomDistance = self.gamepadZoomLevels[i]

		if cameraMaxZoomDistance < cameraMinZoomDistance then
			continue
		end

		if cameraMinZoomDistance < localPlayer.CameraMinZoomDistance then
			cameraMinZoomDistance = localPlayer.CameraMinZoomDistance

			if v and cameraMaxZoomDistance == cameraMinZoomDistance then
				break
			end
		end

		if not v and cameraMaxZoomDistance == cameraMinZoomDistance then
			break
		end

		if cameraMinZoomDistance + (cameraMaxZoomDistance - cameraMinZoomDistance) / 2 < cameraToSubjectDistance then
			self:SetCameraToSubjectDistance(cameraMinZoomDistance)
			return
		else
			cameraMaxZoomDistance = cameraMinZoomDistance
		end
	end

	self:SetCameraToSubjectDistance(self.gamepadZoomLevels[#self.gamepadZoomLevels])
end

function BaseCamera:Enable(enabled: boolean)
	if self.enabled ~= enabled then
		self.enabled = enabled
		self:OnEnabledChanged()
	end
end

function BaseCamera:OnEnabledChanged()
	if self.enabled then
		self:_setUpConfigurations()
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

		if self.cameraChangedConn then
			self.cameraChangedConn:Disconnect()
			self.cameraChangedConn = nil
		end

		self.cameraChangedConn = workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
			self:OnCurrentCameraChanged()
		end)
		self:OnCurrentCameraChanged()
	else
		self._connections:disconnectAll()
		CameraInput.setInputEnabled(false)

		if self.gamepadZoomPressConnection then
			self.gamepadZoomPressConnection:Disconnect()
			self.gamepadZoomPressConnection = nil
		end

		self:Cleanup()
	end
end

function BaseCamera:GetEnabled()
	return self.enabled
end

function BaseCamera:Cleanup()
	if self.subjectStateChangedConn then
		self.subjectStateChangedConn:Disconnect()
		self.subjectStateChangedConn = nil
	end

	if not userFlag and self.viewportSizeChangedConn then
		self.viewportSizeChangedConn:Disconnect()
		self.viewportSizeChangedConn = nil
	end

	if self.cameraChangedConn then
		self.cameraChangedConn:Disconnect()
		self.cameraChangedConn = nil
	end

	self.lastCameraTransform = nil
	self.lastSubjectCFrame = nil
	CameraUtils.restoreMouseBehavior()
end

function BaseCamera:UpdateMouseBehavior()
	local v2 = UserGameSettings.ComputerMovementMode == Enum.ComputerMovementMode.ClickToMove

	if self.isCameraToggle and v2 == false then
		CameraUI.setCameraModeToastEnabled(true)
		CameraInput.enableCameraToggleInput()
		CameraToggleStateController(self.inFirstPerson)
	else
		CameraUI.setCameraModeToastEnabled(false)
		CameraInput.disableCameraToggleInput()

		if self.inFirstPerson or self.inMouseLockedMode then
			CameraUtils.setRotationTypeOverride(Enum.RotationType.CameraRelative)
			CameraUtils.setMouseBehaviorOverride(Enum.MouseBehavior.LockCenter)
		else
			CameraUtils.restoreRotationType()

			if CameraInput.getRotationActivated() then
				CameraUtils.setMouseBehaviorOverride(Enum.MouseBehavior.LockCurrentPosition)
			else
				CameraUtils.restoreMouseBehavior()
			end
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

function BaseCamera:GetIsMouseLocked()
	return self.inMouseLockedMode
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

function BaseCamera:EnterFirstPerson()
	self.inFirstPerson = true
	self:UpdateMouseBehavior()
end

function BaseCamera:LeaveFirstPerson()
	self.inFirstPerson = false
	self:UpdateMouseBehavior()
end

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
	local v2 = vector2 or self:GetCameraLookVector()
	local v3 = math.asin(v2.Y)
	local v4 = math.clamp(point.Y, v3 + -1.3962634015954636, v3 + 1.3962634015954636)
	local vector3 = Vector2.new(point.X, v4)
	local cframe = CFrame.new(createVector(0, 0, 0), v2)
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

	local v2 = p.humanoidCache[localPlayer]

	if v2 and v2.Parent == character then
		return v2
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