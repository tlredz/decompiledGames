local vector = Vector2.new(0, 0)
local clamped = 0
local cframe = CFrame.fromOrientation(-0.2617993877991494, 0, 0)
local Players = game:GetService("Players")
local VRService = game:GetService("VRService")
local CameraUtils = require(script.Parent:WaitForChild("CameraUtils"))
local BaseCamera = require(script.Parent:WaitForChild("BaseCamera"))
local object = setmetatable({}, BaseCamera)
object.__index = object

function object.new()
	local self = setmetatable(BaseCamera.new(), object)
	self.isFollowCamera = false
	self.lastUpdate = tick()
	return self
end

function object.GetModuleName(_)
	return "ClassicCamera"
end

function object:SetCameraMovementMode(p2)
	BaseCamera.SetCameraMovementMode(self, p2)
	self.isFollowCamera = p2 == Enum.ComputerCameraMovementMode.Follow
end

function object.Test(_)
	print("ClassicCamera:Test()")
end

function object:Update()
	local now = tick()
	local v = now - self.lastUpdate
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
	local v2 = cameraSubject and cameraSubject:IsA("VehicleSeat")
	local v3 = cameraSubject and cameraSubject:IsA("SkateboardPlatform")
	local v4 = humanoid and humanoid:GetState() == Enum.HumanoidStateType.Climbing

	if self.lastUpdate == nil or v > 1 then
		self.lastCameraTransform = nil
	end

	if self.lastUpdate then
		local v5 = self:UpdateGamepad()

		if self:ShouldUseVRRotation() then
			self.rotateInput += self:GetVRRotationInput()
		else
			local v6 = math.min(0.1, v)

			if v5 ~= vector then
				self.rotateInput += v5 * v6
			end

			local v7 = 0

			if not (v2 or v3) then
				v7 = v7 + (self.turningLeft and -120 or 0) + (self.turningRight and 120 or 0)
			end

			if v7 ~= 0 then
				self.rotateInput += Vector2.new(math.rad(v7 * v6), 0)
			end
		end
	end

	if self.userPanningTheCamera then
		clamped = 0
		self.lastUserPanCamera = tick()
	end

	local v5 = now - self.lastUserPanCamera < 2
	local subjectPosition = self:GetSubjectPosition()

	if subjectPosition and localPlayer and currentCamera then
		local cameraToSubjectDistance = self:GetCameraToSubjectDistance()
		local v6 = cameraToSubjectDistance < 0.5 and 0.5 or cameraToSubjectDistance

		if self:GetIsMouseLocked() and not self:IsInFirstPerson() then
			local newLookCFrame = self:CalculateNewLookCFrame(lookVector)
			local mouseLockOffset = self:GetMouseLockOffset()
			local v7 = mouseLockOffset.X * newLookCFrame.rightVector + mouseLockOffset.Y * newLookCFrame.upVector + mouseLockOffset.Z * newLookCFrame.lookVector

			if CameraUtils.IsFiniteVector3(v7) then
				subjectPosition += v7
			end
		elseif not self.userPanningTheCamera and self.lastCameraTransform then
			local isInFirstPerson = self:IsInFirstPerson()

			if (v2 or v3 or self.isFollowCamera and v4) and self.lastUpdate and humanoid and humanoid.Torso then
				if isInFirstPerson then
					if self.lastSubjectCFrame and (v2 or v3) and cameraSubject:IsA("BasePart") then
						local v7 = -CameraUtils.GetAngleBetweenXZVectors(
							self.lastSubjectCFrame.lookVector,
							cameraSubject.CFrame.lookVector
						)

						if CameraUtils.IsFinite(v7) then
							self.rotateInput += Vector2.new(v7, 0)
						end

						clamped = 0
					end
				elseif not v5 then
					local lookVector2 = humanoid.Torso.CFrame.lookVector

					if v3 then
						lookVector2 = cameraSubject.CFrame.lookVector
					end

					clamped = CameraUtils.Clamp(0, 4.363323129985824, clamped + 3.839724354387525 * v)
					local clamped2 = CameraUtils.Clamp(0, 1, clamped * v)
					local v7 = self:IsInFirstPerson() and not (self.isFollowCamera and self.isClimbing) and 1 or clamped2
					local angleBetweenXZVectors = CameraUtils.GetAngleBetweenXZVectors(
						lookVector2,
						self:GetCameraLookVector()
					)

					if CameraUtils.IsFinite(angleBetweenXZVectors) and math.abs(angleBetweenXZVectors) > 0.0001 then
						self.rotateInput += Vector2.new(angleBetweenXZVectors * v7, 0)
					end
				end
			elseif self.isFollowCamera and not (isInFirstPerson or v5 or VRService.VREnabled) then
				local v7 = -(self.lastCameraTransform.p - subjectPosition)
				local angleBetweenXZVectors = CameraUtils.GetAngleBetweenXZVectors(v7, self:GetCameraLookVector())

				if CameraUtils.IsFinite(angleBetweenXZVectors) and math.abs(angleBetweenXZVectors) > 0.0001 then
					local v8 = math.abs(angleBetweenXZVectors)

					if 0.4 * v < v8 then
						self.rotateInput += Vector2.new(angleBetweenXZVectors, 0)
					end
				end
			end
		end

		if self.isFollowCamera then
			local newLookVector = self:CalculateNewLookVector(lookVector)
			self.rotateInput = vector

			if VRService.VREnabled then
				focus = self:GetVRFocus(subjectPosition, v)
			else
				focus = CFrame.new(subjectPosition)
			end

			cFrame = CFrame.new(focus.p - v6 * newLookVector, focus.p) + Vector3.new(0, self:GetCameraHeight(), 0)
		else
			local vREnabled = VRService.VREnabled

			if vREnabled then
				focus = self:GetVRFocus(subjectPosition, v)
			else
				focus = CFrame.new(subjectPosition)
			end

			local p = focus.p

			if vREnabled and not self:IsInFirstPerson() then
				local cameraHeight = self:GetCameraHeight()
				local magnitude = (subjectPosition - currentCamera.CFrame.p).magnitude

				if v6 < magnitude or self.rotateInput.x ~= 0 then
					local v7 = math.min(magnitude, v6)
					local v8 = self:CalculateNewLookVectorVR() * v7
					local v9 = p - v8
					local lookVector2 = currentCamera.CFrame.lookVector

					if self.rotateInput.x ~= 0 then
						lookVector2 = v8
					end

					local vector2 = Vector3.new(v9.x + lookVector2.x, v9.y, v9.z + lookVector2.z)
					self.rotateInput = vector
					cFrame = CFrame.new(v9, vector2) + Vector3.new(0, cameraHeight, 0)
				end
			else
				local newLookVector = self:CalculateNewLookVector(lookVector)
				self.rotateInput = vector
				cFrame = CFrame.new(p - v6 * newLookVector, p)
			end
		end

		self.lastCameraTransform = cFrame
		self.lastCameraFocus = focus

		if (v2 or v3) and cameraSubject:IsA("BasePart") then
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