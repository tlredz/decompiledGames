local createVector = vector.create
local Players = game:GetService("Players")
local VRService = game:GetService("VRService")
UserSettings():GetService("UserGameSettings")
require(script.Parent:WaitForChild("CameraInput"))
require(script.Parent:WaitForChild("CameraUtils"))
local VRBaseCamera = require(script.Parent:WaitForChild("VRBaseCamera"))
local object = setmetatable({}, VRBaseCamera)
object.__index = object

function object.new()
	local self = setmetatable(VRBaseCamera.new(), object)
	self.lastUpdate = tick()
	self.focusOffset = CFrame.new()
	self:Reset()
	self.controlModule = require(Players.LocalPlayer:WaitForChild("PlayerScripts").PlayerModule:WaitForChild("ControlModule"))
	self.savedAutoRotate = true
	return self
end

function object:Reset()
	self.needsReset = true
	self.needsBlackout = true
	self.motionDetTime = 0
	self.blackOutTimer = 0
	self.lastCameraResetPosition = nil
	VRBaseCamera.Reset(self)
end

function object:Update(value)
	local currentCamera = workspace.CurrentCamera
	local cFrame = currentCamera.CFrame
	local focus = currentCamera.Focus
	local localPlayer = Players.LocalPlayer
	self:GetHumanoid()
	local _ = currentCamera.CameraSubject

	if self.lastUpdate == nil or value > 1 then
		self.lastCameraTransform = nil
	end

	self:UpdateFadeFromBlack(value)
	self:UpdateEdgeBlur(localPlayer, value)
	local lastSubjectPosition = self.lastSubjectPosition
	local subjectPosition = self:GetSubjectPosition()

	if self.needsBlackout then
		self:StartFadeFromBlack()
		local v = math.clamp(value, 0.0001, 0.1)
		self.blackOutTimer += v

		if self.blackOutTimer > 0.1 and game:IsLoaded() then
			self.needsBlackout = false
			self.needsReset = true
		end
	end

	if subjectPosition and localPlayer and currentCamera then
		local vRFocus = self:GetVRFocus(subjectPosition, value)

		if self:IsInFirstPerson() then
			if VRService.AvatarGestures then
				cFrame, focus = self:UpdateImmersionCamera(value, cFrame, vRFocus, lastSubjectPosition, subjectPosition)
			else
				cFrame, focus = self:UpdateFirstPersonTransform(
					value,
					cFrame,
					vRFocus,
					lastSubjectPosition,
					subjectPosition
				)
			end
		elseif VRService.ThirdPersonFollowCamEnabled then
			cFrame, focus = self:UpdateThirdPersonFollowTransform(
				value,
				cFrame,
				vRFocus,
				lastSubjectPosition,
				subjectPosition
			)
		else
			cFrame, focus = self:UpdateThirdPersonComfortTransform(
				value,
				cFrame,
				vRFocus,
				lastSubjectPosition,
				subjectPosition
			)
		end

		self.lastCameraTransform = cFrame
		self.lastCameraFocus = focus
	end

	self.lastUpdate = tick()
	return cFrame, focus
end

function object.GetAvatarFeetWorldYValue(_)
	local cameraSubject = workspace.CurrentCamera.CameraSubject

	if not cameraSubject then
		return nil
	end

	if cameraSubject:IsA("Humanoid") and cameraSubject.RootPart then
		local rootPart = cameraSubject.RootPart
		return rootPart.Position.Y - rootPart.Size.Y / 2 - cameraSubject.HipHeight
	else
		return nil
	end
end

function object:UpdateFirstPersonTransform(p, _, p2, p3, p4)
	if self.needsReset then
		self:StartFadeFromBlack()
		self.needsReset = false
	end

	local localPlayer = Players.LocalPlayer

	if (p3 - p4).magnitude > 0.01 then
		self:StartVREdgeBlur(localPlayer)
	end

	local p5 = p2.p
	local cameraLookVector = self:GetCameraLookVector()
	local unit = Vector3.new(cameraLookVector.X, 0, cameraLookVector.Z).Unit
	local rotation = self:getRotation(p)
	local newLookVectorFromArg = self:CalculateNewLookVectorFromArg(unit, Vector2.new(rotation, 0))
	return CFrame.new(p5 - 0.5 * newLookVectorFromArg, p5), p2
end

function object:UpdateImmersionCamera(p, _, _, _, p2)
	local subjectCFrame = self:GetSubjectCFrame()
	local currentCamera = workspace.CurrentCamera
	local character = Players.LocalPlayer.Character
	local humanoid = self:GetHumanoid()

	if not humanoid then
		return currentCamera.CFrame, currentCamera.Focus
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return currentCamera.CFrame, currentCamera.Focus
	end

	self.characterOrientation = humanoidRootPart:FindFirstChild("CharacterAlignOrientation")

	if not self.characterOrientation then
		local rootAttachment = humanoidRootPart:FindFirstChild("RootAttachment")

		if not rootAttachment then
			return
		end

		self.characterOrientation = Instance.new("AlignOrientation")
		self.characterOrientation.Name = "CharacterAlignOrientation"
		self.characterOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
		self.characterOrientation.Attachment0 = rootAttachment
		self.characterOrientation.RigidityEnabled = true
		self.characterOrientation.Parent = humanoidRootPart
	end

	if self.characterOrientation.Enabled == false then
		self.characterOrientation.Enabled = true
	end

	if self.needsReset then
		self.needsReset = false
		self.savedAutoRotate = humanoid.AutoRotate
		humanoid.AutoRotate = false

		if self.NoRecenter then
			self.NoRecenter = false
			VRService:RecenterUserHeadCFrame()
		end

		self:StartFadeFromBlack()
	elseif humanoid.Sit then
		if (subjectCFrame.Position - currentCamera.CFrame.Position).Magnitude > 0.01 then
			self:StartVREdgeBlur(Players.LocalPlayer)
		end
	else
		local estimatedVRTorsoFrame = self.controlModule:GetEstimatedVRTorsoFrame()
		self.characterOrientation.CFrame = currentCamera.CFrame * estimatedVRTorsoFrame

		if self.controlModule.inputMoveVector.Magnitude > 0 then
			self.motionDetTime = 0.1
		end

		if self.controlModule.inputMoveVector.Magnitude > 0 or self.motionDetTime > 0 then
			self.motionDetTime -= p
			self:StartVREdgeBlur(Players.LocalPlayer)
			local userCFrame = VRService:GetUserCFrame(Enum.UserCFrame.Head)
			local v = userCFrame.Rotation + userCFrame.Position * currentCamera.HeadScale
			local humanoidRootPart2 = character.HumanoidRootPart
			local v2 = -0.7 * humanoidRootPart2.Size.Y / 2
			local v3 = currentCamera.CFrame * v * CFrame.new(0, v2, 0)
			local lookVector = humanoidRootPart2.CFrame.LookVector
			local v4 = p2 - (v3 - Vector3.new(lookVector.X, 0, lookVector.Z).Unit * humanoidRootPart2.Size.Y * 0.125).Position + currentCamera.CFrame.Position
			local vector2 = Vector3.new(v4.X, p2.Y, v4.Z)
			subjectCFrame = currentCamera.CFrame.Rotation + vector2
		else
			subjectCFrame = currentCamera.CFrame.Rotation + Vector3.new(
				currentCamera.CFrame.Position.X,
				p2.Y,
				currentCamera.CFrame.Position.Z
			)
		end

		local rotation = self:getRotation(p)

		if math.abs(rotation) > 0 then
			local userCFrame = VRService:GetUserCFrame(Enum.UserCFrame.Head)
			local cframe = userCFrame.Rotation + userCFrame.Position * currentCamera.HeadScale
			local v = subjectCFrame * cframe
			subjectCFrame = CFrame.new(v.Position) * CFrame.Angles(0, -math.rad(rotation * 90), 0) * v.Rotation * cframe:Inverse()
		end
	end

	return subjectCFrame, subjectCFrame * CFrame.new(0, 0, -0.5)
end

function object:UpdateThirdPersonComfortTransform(p, cframe, cframe2, p2, lastCameraResetPosition)
	local cameraToSubjectDistance = self:GetCameraToSubjectDistance()
	local v = cameraToSubjectDistance < 0.5 and 0.5 or cameraToSubjectDistance

	if p2 == nil or self.lastCameraFocus == nil then
		return cframe, cframe2
	end

	local _ = Players.LocalPlayer
	local v2 = p2 - lastCameraResetPosition
	local moveVector = self.controlModule:GetMoveVector()
	local v3 = v2.magnitude > 0.01 or moveVector.magnitude > 0.01

	if v3 then
		self.motionDetTime = 0.1
	end

	self.motionDetTime -= p

	if (self.motionDetTime > 0 or v3) and not self.needsReset then
		local lastCameraFocus = self.lastCameraFocus
		self.VRCameraFocusFrozen = true
		return cframe, lastCameraFocus
	else
		local v4 = self.lastCameraResetPosition == nil or (lastCameraResetPosition - self.lastCameraResetPosition).Magnitude > 1
		local rotation = self:getRotation(p)

		if math.abs(rotation) > 0 then
			local objectSpace = cframe2:ToObjectSpace(cframe)
			cframe = cframe2 * CFrame.Angles(0, -rotation, 0) * objectSpace
		end

		if not (self.VRCameraFocusFrozen and v4 or self.needsReset) then
			return cframe, cframe2
		end

		VRService:RecenterUserHeadCFrame()
		self.VRCameraFocusFrozen = false
		self.needsReset = false
		self.lastCameraResetPosition = lastCameraResetPosition
		self:ResetZoom()
		self:StartFadeFromBlack()
		local humanoid = self:GetHumanoid()
		local lookVector = humanoid.Torso and humanoid.Torso.CFrame.lookVector or createVector(1, 0, 0)
		local vector2 = Vector3.new(lookVector.X, 0, lookVector.Z)
		local v5 = cframe2.Position - vector2 * v
		local vector3 = Vector3.new(cframe2.Position.X, v5.Y, cframe2.Position.Z)
		cframe = CFrame.new(v5, vector3)
		return cframe, cframe2
	end
end

function object:UpdateThirdPersonFollowTransform(p, _, _, p2, p3)
	local currentCamera = workspace.CurrentCamera
	local cameraToSubjectDistance = self:GetCameraToSubjectDistance()
	local vRFocus = self:GetVRFocus(p3, p)

	if self.needsReset then
		self.needsReset = false
		VRService:RecenterUserHeadCFrame()
		self:ResetZoom()
		self:StartFadeFromBlack()
	end

	if self.recentered then
		local subjectCFrame = self:GetSubjectCFrame()

		if not subjectCFrame then
			return currentCamera.CFrame, currentCamera.Focus
		end

		local v = vRFocus * subjectCFrame.Rotation * CFrame.new(0, 0, cameraToSubjectDistance)
		self.focusOffset = vRFocus:ToObjectSpace(v)
		self.recentered = false
		return v, vRFocus
	else
		local worldSpace = vRFocus:ToWorldSpace(self.focusOffset)
		local _ = Players.LocalPlayer
		local v = p2 - p3
		local controlModule = self.controlModule
		local moveVector = controlModule:GetMoveVector()

		if v.magnitude > 0.01 or moveVector.magnitude > 0 then
			local estimatedVRTorsoFrame = controlModule:GetEstimatedVRTorsoFrame()
			local v2 = estimatedVRTorsoFrame.Rotation + estimatedVRTorsoFrame.Position * currentCamera.HeadScale
			local v3 = currentCamera.CFrame * v2
			local lookVector = v3.LookVector
			local v4 = Vector3.new(lookVector.X, 0, lookVector.Z).Unit * cameraToSubjectDistance
			local v5 = vRFocus.Position - v4
			worldSpace = worldSpace:Lerp(
				CFrame.new(currentCamera.CFrame.Position + v5 - v3.Position) * worldSpace.Rotation,
				0.01
			)
		end

		local rotation = self:getRotation(p)

		if math.abs(rotation) > 0 then
			local objectSpace = vRFocus:ToObjectSpace(worldSpace)
			worldSpace = vRFocus * CFrame.Angles(0, -rotation, 0) * objectSpace
		end

		self.focusOffset = vRFocus:ToObjectSpace(worldSpace)
		local v2 = worldSpace * CFrame.new(0, 0, -cameraToSubjectDistance)

		if (v2.Position - currentCamera.Focus.Position).Magnitude > 0.01 then
			self:StartVREdgeBlur(Players.LocalPlayer)
		end

		return worldSpace, v2
	end
end

function object:LeaveFirstPerson()
	VRBaseCamera.LeaveFirstPerson(self)
	self.needsReset = true

	if self.VRBlur then
		self.VRBlur.Visible = false
	end

	if self.characterOrientation then
		self.characterOrientation.Enabled = false
	end

	local humanoid = self:GetHumanoid()

	if humanoid then
		humanoid.AutoRotate = self.savedAutoRotate
	end
end

return object