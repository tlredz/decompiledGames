Vector2.new(0, 0)
local v = 0
local cframe = CFrame.fromOrientation(-0.2617993877991494, 0, 0)
local Players = game:GetService("Players")
local VRService = game:GetService("VRService")
local CameraInput = require(script.Parent:WaitForChild("CameraInput"))
local CameraUtils = require(script.Parent:WaitForChild("CameraUtils"))
local BaseCamera = require(script.Parent:WaitForChild("BaseCamera"))
local object = setmetatable({}, BaseCamera)
object.__index = object

function object.new()
	local self = setmetatable(BaseCamera.new(), object)
	self.isFollowCamera = false
	self.isCameraToggle = false
	self.lastUpdate = tick()
	self.cameraToggleSpring = CameraUtils.Spring.new(5, 0)
	return self
end

function object:GetCameraToggleOffset(p: number)
	if not self.isCameraToggle then
		return (Vector3.new())
	end

	local currentSubjectDistance = self.currentSubjectDistance

	if CameraInput.getTogglePan() then
		self.cameraToggleSpring.goal = math.clamp(
			CameraUtils.map(currentSubjectDistance, 0.5, self.FIRST_PERSON_DISTANCE_THRESHOLD, 0, 1),
			0,
			1
		)
	else
		self.cameraToggleSpring.goal = 0
	end

	local v2 = math.clamp(CameraUtils.map(currentSubjectDistance, 0.5, 64, 0, 1), 0, 1) + 1
	return (Vector3.new(0, self.cameraToggleSpring:step(p) * v2, 0))
end

function object:SetCameraMovementMode(p2)
	BaseCamera.SetCameraMovementMode(self, p2)
	self.isFollowCamera = p2 == Enum.ComputerCameraMovementMode.Follow
	self.isCameraToggle = p2 == Enum.ComputerCameraMovementMode.CameraToggle
end

function object:Update()
	local now = tick()
	local v2 = now - self.lastUpdate
	local currentCamera = workspace.CurrentCamera
	local cFrame = currentCamera.CFrame
	local focus = currentCamera.Focus
	local lookVector

	if self.resetCameraAngle then
		local humanoidRootPart = self:GetHumanoidRootPart()

		if humanoidRootPart then
			lookVector = (humanoidRootPart.CFrame * cframe).lookVector
		else
			lookVector = cframe.lookVector
		end

		self.resetCameraAngle = false
	end

	local localPlayer = Players.LocalPlayer
	local humanoid = self:GetHumanoid()
	local cameraSubject = currentCamera.CameraSubject
	local v3 = cameraSubject and cameraSubject:IsA("VehicleSeat")
	local v4 = cameraSubject and cameraSubject:IsA("SkateboardPlatform")
	local v5 = humanoid and humanoid:GetState() == Enum.HumanoidStateType.Climbing

	if self.lastUpdate == nil or v2 > 1 then
		self.lastCameraTransform = nil
	end

	local rotation = CameraInput.getRotation()
	self:StepZoom()
	local cameraHeight = self:GetCameraHeight()

	if CameraInput.getRotation() ~= Vector2.new() then
		v = 0
		self.lastUserPanCamera = tick()
	end

	local v6 = now - self.lastUserPanCamera < 2
	local subjectPosition = self:GetSubjectPosition()

	if subjectPosition and localPlayer and currentCamera then
		local cameraToSubjectDistance = self:GetCameraToSubjectDistance()
		local v7 = cameraToSubjectDistance < 0.5 and 0.5 or cameraToSubjectDistance

		if self:GetIsMouseLocked() and not self:IsInFirstPerson() then
			local newLookCFrameFromArg = self:CalculateNewLookCFrameFromArg(lookVector, rotation)
			local mouseLockOffset = self:GetMouseLockOffset()
			local v8 = mouseLockOffset.X * newLookCFrameFromArg.RightVector + mouseLockOffset.Y * newLookCFrameFromArg.UpVector + mouseLockOffset.Z * newLookCFrameFromArg.LookVector

			if CameraUtils.IsFiniteVector3(v8) then
				subjectPosition += v8
			end
		elseif CameraInput.getRotation() == Vector2.new() and self.lastCameraTransform then
			local isInFirstPerson = self:IsInFirstPerson()

			if (v3 or v4 or self.isFollowCamera and v5) and self.lastUpdate and humanoid and humanoid.Torso then
				if isInFirstPerson then
					if self.lastSubjectCFrame and (v3 or v4) and cameraSubject:IsA("BasePart") then
						local v8 = -CameraUtils.GetAngleBetweenXZVectors(
							self.lastSubjectCFrame.lookVector,
							cameraSubject.CFrame.lookVector
						)

						if CameraUtils.IsFinite(v8) then
							rotation += Vector2.new(v8, 0)
						end

						v = 0
					end
				elseif not v6 then
					local lookVector2 = humanoid.Torso.CFrame.lookVector
					v = math.clamp(v + 3.839724354387525 * v2, 0, 4.363323129985824)
					local v8 = math.clamp(v * v2, 0, 1)
					local v9 = self:IsInFirstPerson() and not (self.isFollowCamera and self.isClimbing) and 1 or v8
					local angleBetweenXZVectors = CameraUtils.GetAngleBetweenXZVectors(
						lookVector2,
						self:GetCameraLookVector()
					)

					if CameraUtils.IsFinite(angleBetweenXZVectors) and math.abs(angleBetweenXZVectors) > 0.0001 then
						rotation += Vector2.new(angleBetweenXZVectors * v9, 0)
					end
				end
			elseif self.isFollowCamera and not (isInFirstPerson or v6 or VRService.VREnabled or currentCamera:GetAttribute("AimAssist")) then
				local v8 = -(self.lastCameraTransform.p - subjectPosition)
				local angleBetweenXZVectors = CameraUtils.GetAngleBetweenXZVectors(v8, self:GetCameraLookVector())

				if CameraUtils.IsFinite(angleBetweenXZVectors) and math.abs(angleBetweenXZVectors) > 0.0001 then
					local v9 = math.abs(angleBetweenXZVectors)

					if 0.4 * v2 < v9 then
						rotation += Vector2.new(angleBetweenXZVectors, 0)
					end
				end
			end
		end

		local vRFocus

		if self.isFollowCamera then
			local newLookVectorFromArg = self:CalculateNewLookVectorFromArg(lookVector, rotation)

			if VRService.VREnabled then
				vRFocus = self:GetVRFocus(subjectPosition, v2)
			else
				vRFocus = CFrame.new(subjectPosition)
			end

			cFrame = CFrame.new(vRFocus.p - v7 * newLookVectorFromArg, vRFocus.p) + Vector3.new(0, cameraHeight, 0)
		else
			local vREnabled = VRService.VREnabled

			if vREnabled then
				vRFocus = self:GetVRFocus(subjectPosition, v2)
			else
				vRFocus = CFrame.new(subjectPosition)
			end

			local p = vRFocus.p

			if vREnabled and not self:IsInFirstPerson() then
				local magnitude = (subjectPosition - currentCamera.CFrame.p).magnitude

				if v7 < magnitude or rotation.x ~= 0 then
					local v8 = math.min(magnitude, v7)
					local v9 = self:CalculateNewLookVectorFromArg(nil, rotation) * v8
					local v10 = p - v9
					local lookVector2 = currentCamera.CFrame.lookVector

					if rotation.x ~= 0 then
						lookVector2 = v9
					end

					local vector = Vector3.new(v10.x + lookVector2.x, v10.y, v10.z + lookVector2.z)
					cFrame = CFrame.new(v10, vector) + Vector3.new(0, cameraHeight, 0)
				end
			else
				local newLookVectorFromArg = self:CalculateNewLookVectorFromArg(lookVector, rotation)
				cFrame = CFrame.new(p - v7 * newLookVectorFromArg, p)
			end
		end

		local cameraToggleOffset = self:GetCameraToggleOffset(v2)
		focus = vRFocus + cameraToggleOffset
		cFrame += cameraToggleOffset
		self.lastCameraTransform = cFrame
		self.lastCameraFocus = focus

		if (v3 or v4) and cameraSubject:IsA("BasePart") then
			self.lastSubjectCFrame = cameraSubject.CFrame
		else
			self.lastSubjectCFrame = nil
		end
	end

	self.lastUpdate = now
	return cFrame, focus
end

function object:EnterFirstPerson()
	self.inFirstPerson = true
	self:UpdateMouseBehavior()
end

function object:LeaveFirstPerson()
	self.inFirstPerson = false
	self:UpdateMouseBehavior()
end

return object