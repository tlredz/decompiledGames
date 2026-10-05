local createVector = vector.create
local success, result = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserVRVehicleCameraOrbital")
end)
local v = success and result
local VRService = game:GetService("VRService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserGameSettings = UserSettings():GetService("UserGameSettings")
local CameraInput = require(script.Parent:WaitForChild("CameraInput"))
local ZoomController = require(script.Parent:WaitForChild("ZoomController"))
local commonUtils = script.Parent.Parent:WaitForChild("CommonUtils")
require(commonUtils:WaitForChild("FlagUtil"))
local BaseCamera = require(script.Parent:WaitForChild("BaseCamera"))
local object = setmetatable({}, BaseCamera)
object.__index = object

function object.new()
	local self = setmetatable(BaseCamera.new(), object)
	self.gamepadZoomLevels = { 0, 7 }
	self.headScale = 1
	self:SetCameraToSubjectDistance(7)
	self.VRFadeResetTimer = 0
	self.VREdgeBlurTimer = 0
	self.gamepadResetConnection = nil
	self.needsReset = true
	self.recentered = false
	self:Reset()
	return self
end

function object:Reset()
	self.stepRotateTimeout = 0
end

function object.GetModuleName(_)
	return "VRBaseCamera"
end

function object:GamepadZoomPress()
	BaseCamera.GamepadZoomPress(self)
	self:GamepadReset()
	self:ResetZoom()
end

function object:GamepadReset()
	self.stepRotateTimeout = 0
	self.needsReset = true
end

function object:ResetZoom()
	ZoomController.SetZoomParameters(self.currentSubjectDistance, 0)
	ZoomController.ReleaseSpring()
end

function object:OnEnabledChanged()
	BaseCamera.OnEnabledChanged(self)

	if self.enabled then
		self.gamepadResetConnection = CameraInput.gamepadReset:Connect(function()
			self:GamepadReset()
		end)
		self.thirdPersonOptionChanged = VRService:GetPropertyChangedSignal("ThirdPersonFollowCamEnabled"):Connect(function()
			if v then
				self:Reset()
			elseif not self:IsInFirstPerson() then
				self:Reset()
			end
		end)
		self.vrRecentered = VRService.UserCFrameChanged:Connect(function(p, _)
			if p == Enum.UserCFrame.Floor then
				self.recentered = true
			end
		end)
	else
		if self.inFirstPerson then
			self:GamepadZoomPress()
		end

		if self.thirdPersonOptionChanged then
			self.thirdPersonOptionChanged:Disconnect()
			self.thirdPersonOptionChanged = nil
		end

		if self.vrRecentered then
			self.vrRecentered:Disconnect()
			self.vrRecentered = nil
		end

		if self.cameraHeadScaleChangedConn then
			self.cameraHeadScaleChangedConn:Disconnect()
			self.cameraHeadScaleChangedConn = nil
		end

		if self.gamepadResetConnection then
			self.gamepadResetConnection:Disconnect()
			self.gamepadResetConnection = nil
		end

		self.VREdgeBlurTimer = 0
		self:UpdateEdgeBlur(localPlayer, 1)
		local vRFade = Lighting:FindFirstChild("VRFade")

		if vRFade then
			vRFade.Brightness = 0
		end
	end
end

function object:OnCurrentCameraChanged()
	BaseCamera.OnCurrentCameraChanged(self)

	if self.cameraHeadScaleChangedConn then
		self.cameraHeadScaleChangedConn:Disconnect()
		self.cameraHeadScaleChangedConn = nil
	end

	local currentCamera = workspace.CurrentCamera

	if currentCamera then
		self.cameraHeadScaleChangedConn = currentCamera:GetPropertyChangedSignal("HeadScale"):Connect(function()
			self:OnHeadScaleChanged()
		end)
		self:OnHeadScaleChanged()
	end
end

function object:OnHeadScaleChanged()
	local headScale = workspace.CurrentCamera.HeadScale

	for k, gamepadZoomLevel in self.gamepadZoomLevels do
		self.gamepadZoomLevels[k] = gamepadZoomLevel * headScale / self.headScale
	end

	self:SetCameraToSubjectDistance(self:GetCameraToSubjectDistance() * headScale / self.headScale)
	self.headScale = headScale
end

function object:GetVRFocus(p, p2)
	local lastCameraFocus = self.lastCameraFocus or p
	self.cameraTranslationConstraints = Vector3.new(
		self.cameraTranslationConstraints.x,
		math.min(1, self.cameraTranslationConstraints.y + p2),
		self.cameraTranslationConstraints.z
	)
	local vector2 = Vector3.new(0, self:GetCameraHeight(), 0)
	return (CFrame.new(Vector3.new(p.x, lastCameraFocus.y, p.z):Lerp(p + vector2, self.cameraTranslationConstraints.y)))
end

function object:StartFadeFromBlack()
	if UserGameSettings.VignetteEnabled == false then
		return
	end

	local v2 = Lighting:FindFirstChild("VRFade")

	if not v2 then
		v2 = Instance.new("ColorCorrectionEffect")
		v2.Name = "VRFade"
		v2.Parent = Lighting
	end

	v2.Brightness = -1
	self.VRFadeResetTimer = 0.1
end

function object:UpdateFadeFromBlack(p2: number)
	local vRFade = Lighting:FindFirstChild("VRFade")

	if self.VRFadeResetTimer > 0 then
		self.VRFadeResetTimer = math.max(self.VRFadeResetTimer - p2, 0)
		local vRFade2 = Lighting:FindFirstChild("VRFade")

		if vRFade2 and vRFade2.Brightness < 0 then
			vRFade2.Brightness = math.min(vRFade2.Brightness + p2 * 10, 0)
		end
	elseif vRFade then
		vRFade.Brightness = 0
	end
end

function object:StartVREdgeBlur(p2, p3)
	if not p3 and UserGameSettings.VignetteEnabled == false then
		return
	end

	local adornee = workspace.CurrentCamera:FindFirstChild("VRBlurPart")

	if not adornee then
		adornee = Instance.new("Part")
		adornee.Name = "VRBlurPart"
		adornee.Parent = workspace.CurrentCamera
		adornee.CanTouch = false
		adornee.CanCollide = false
		adornee.CanQuery = false
		adornee.Anchored = true
		adornee.Size = createVector(0.44, 0.47, 1)
		adornee.Transparency = 1
		adornee.CastShadow = false
		RunService.RenderStepped:Connect(function(_)
			local userCFrame = VRService:GetUserCFrame(Enum.UserCFrame.Head)
			local v3 = workspace.CurrentCamera.CFrame * (CFrame.new(userCFrame.p * workspace.CurrentCamera.HeadScale) * (userCFrame - userCFrame.p))
			adornee.CFrame = v3 * CFrame.Angles(0, 3.141592653589793, 0) + v3.LookVector * (1.05 * workspace.CurrentCamera.HeadScale)
			adornee.Size = createVector(0.44, 0.47, 1) * workspace.CurrentCamera.HeadScale
		end)
	end

	local vRBlurScreen = p2.PlayerGui:FindFirstChild("VRBlurScreen")
	local v3

	if vRBlurScreen then
		v3 = vRBlurScreen:FindFirstChild("VRBlur")
	end

	if not v3 then
		local parent = vRBlurScreen or Instance.new("SurfaceGui") or Instance.new("ScreenGui")
		parent.Name = "VRBlurScreen"
		parent.Parent = p2.PlayerGui
		parent.Adornee = adornee
		v3 = Instance.new("ImageLabel")
		v3.Name = "VRBlur"
		v3.Parent = parent
		v3.Image = "rbxasset://textures/ui/VR/edgeBlur.png"
		v3.AnchorPoint = Vector2.new(0.5, 0.5)
		v3.Position = UDim2.new(0.5, 0, 0.5, 0)
		local v5 = workspace.CurrentCamera.ViewportSize.X * 2.3 / 512
		local v6 = workspace.CurrentCamera.ViewportSize.Y * 2.3 / 512
		v3.Size = UDim2.fromScale(v5, v6)
		v3.BackgroundTransparency = 1
		v3.Active = true
		v3.ScaleType = Enum.ScaleType.Stretch
	end

	v3.Visible = true
	v3.ImageTransparency = 0
	self.VREdgeBlurTimer = 0.14
end

function object:UpdateEdgeBlur(p2, p3)
	local vRBlurScreen = p2.PlayerGui:FindFirstChild("VRBlurScreen")
	local vRBlur

	if vRBlurScreen then
		vRBlur = vRBlurScreen:FindFirstChild("VRBlur")
	end

	if vRBlur then
		if self.VREdgeBlurTimer > 0 then
			self.VREdgeBlurTimer -= p3
			local vRBlurScreen2 = p2.PlayerGui:FindFirstChild("VRBlurScreen")
			local vRBlur2 = vRBlurScreen2 and vRBlurScreen2:FindFirstChild("VRBlur")

			if vRBlur2 then
				vRBlur2.ImageTransparency = 1 - math.clamp(self.VREdgeBlurTimer, 0.01, 0.14) * 7.142857142857142
			end
		else
			vRBlur.Visible = false
		end
	end
end

function object:GetCameraHeight()
	if self.inFirstPerson then
		return 0
	end

	return 0.25881904510252074 * self.currentSubjectDistance
end

function object:GetSubjectCFrame()
	local lastSubjectCFrame = BaseCamera.GetSubjectCFrame(self)
	local currentCamera = workspace.CurrentCamera
	local cameraSubject = currentCamera and currentCamera.CameraSubject

	if not cameraSubject then
		return lastSubjectCFrame
	end

	if cameraSubject:IsA("Humanoid") and cameraSubject:GetState() == Enum.HumanoidStateType.Dead and cameraSubject == self.lastSubject then
		lastSubjectCFrame = self.lastSubjectCFrame
	end

	if lastSubjectCFrame then
		self.lastSubjectCFrame = lastSubjectCFrame
	end

	return lastSubjectCFrame
end

function object:GetSubjectPosition()
	local lastSubjectPosition = BaseCamera.GetSubjectPosition(self)
	local currentCamera = game.Workspace.CurrentCamera
	local cameraSubject = currentCamera and currentCamera.CameraSubject

	if not cameraSubject then
		return nil
	end

	if cameraSubject:IsA("Humanoid") then
		if cameraSubject:GetState() == Enum.HumanoidStateType.Dead and cameraSubject == self.lastSubject then
			lastSubjectPosition = self.lastSubjectPosition
		end
	elseif cameraSubject:IsA("VehicleSeat") then
		lastSubjectPosition = cameraSubject.CFrame.p + cameraSubject.CFrame:vectorToWorldSpace(createVector(0, 4, 0))
	end

	self.lastSubjectPosition = lastSubjectPosition
	return lastSubjectPosition
end

function object:getRotation(p)
	local rotation = CameraInput.getRotation(p)

	if UserGameSettings.VRSmoothRotationEnabled then
		return rotation.X
	end

	if math.abs(rotation.X) > 0.03 then
		if self.stepRotateTimeout > 0 then
			self.stepRotateTimeout -= p
		end

		if self.stepRotateTimeout <= 0 then
			local v3 = (rotation.X < 0 and -1 or 1) * 0.5235987755982988
			self:StartFadeFromBlack()
			self.stepRotateTimeout = 0.25
			return v3
		end
	elseif math.abs(rotation.X) < 0.02 then
		self.stepRotateTimeout = 0
	end

	return 0
end

function object.HandleSubjectDistance(object2, object3)
	if v and object3 and object3.IsInFirstPerson and object3:IsInFirstPerson() then
		object2:SetCameraToSubjectDistance(0)
	end
end

return object