local v = 0
local cframe = CFrame.fromOrientation(-0.2617993877991494, 0, 0)
local CommonUtils = require(script.Parent.Parent:WaitForChild("CommonUtils"))
local userFlag = CommonUtils.get("FlagUtil").getUserFlag("UserFixCameraFPError")
local Players = game:GetService("Players")
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

function object:Update(p)
	local now = tick()
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

	if self.lastUpdate == nil or p > 1 then
		self.lastCameraTransform = nil
	end

	local rotation = CameraInput.getRotation(p)
	local v5 = rotation + CameraInput.getAssistRotation()
	self:StepZoom(p)
	local cameraHeight = self:GetCameraHeight()

	if rotation ~= Vector2.new() then
		v = 0
		self.lastUserPanCamera = tick()
	end

	local v6 = now - self.lastUserPanCamera < 2
	local subjectPosition = self:GetSubjectPosition()

	if subjectPosition and localPlayer and currentCamera then
		local cameraToSubjectDistance = self:GetCameraToSubjectDistance()
		local v7 = cameraToSubjectDistance < 0.5 and 0.5 or cameraToSubjectDistance

		if self:GetIsMouseLocked() and not self:IsInFirstPerson() then
			local newLookCFrameFromArg = self:CalculateNewLookCFrameFromArg(lookVector, v5)
			local mouseLockOffset = self:GetMouseLockOffset()

			if humanoid then
				mouseLockOffset += humanoid.CameraOffset
			end

			local v8 = mouseLockOffset.X * newLookCFrameFromArg.RightVector + mouseLockOffset.Y * newLookCFrameFromArg.UpVector + mouseLockOffset.Z * newLookCFrameFromArg.LookVector

			if CameraUtils.IsFiniteVector3(v8) then
				subjectPosition += v8
			end
		elseif rotation == Vector2.new() and self.lastCameraTransform then
			local isInFirstPerson = self:IsInFirstPerson()

			if (v2 or v3 or self.isFollowCamera and v4) and self.lastUpdate and humanoid and humanoid.Torso then
				if isInFirstPerson then
					if self.lastSubjectCFrame and (v2 or v3) and cameraSubject:IsA("BasePart") then
						local v8 = -CameraUtils.GetAngleBetweenXZVectors(
							self.lastSubjectCFrame.lookVector,
							cameraSubject.CFrame.lookVector
						)

						if CameraUtils.IsFinite(v8) then
							v5 += Vector2.new(v8, 0)
						end

						v = 0
					end
				elseif not v6 then
					local lookVector2 = humanoid.Torso.CFrame.lookVector
					v = math.clamp(v + 3.839724354387525 * p, 0, 4.363323129985824)
					local v8 = math.clamp(v * p, 0, 1)
					local v9 = self:IsInFirstPerson() and not (self.isFollowCamera and self.isClimbing) and 1 or v8
					local angleBetweenXZVectors = CameraUtils.GetAngleBetweenXZVectors(
						lookVector2,
						self:GetCameraLookVector()
					)

					if CameraUtils.IsFinite(angleBetweenXZVectors) and math.abs(angleBetweenXZVectors) > 0.0001 then
						v5 += Vector2.new(angleBetweenXZVectors * v9, 0)
					end
				end
			elseif self.isFollowCamera and not (isInFirstPerson or v6) then
				local v8 = -(self.lastCameraTransform.Position - subjectPosition)
				local angleBetweenXZVectors = CameraUtils.GetAngleBetweenXZVectors(v8, self:GetCameraLookVector())

				if CameraUtils.IsFinite(angleBetweenXZVectors) and math.abs(angleBetweenXZVectors) > 0.0001 then
					local v9 = math.abs(angleBetweenXZVectors)

					if 0.4 * p < v9 then
						v5 += Vector2.new(angleBetweenXZVectors, 0)
					end
				end
			end
		end

		local cframe2, cframe3

		if self.isFollowCamera then
			local newLookVectorFromArg = self:CalculateNewLookVectorFromArg(lookVector, v5)
			cframe2 = CFrame.new(subjectPosition)

			if userFlag then
				cframe3 = CFrame.lookAlong(cframe2.Position - v7 * newLookVectorFromArg, newLookVectorFromArg)
			else
				cframe3 = CFrame.new(cframe2.Position - v7 * newLookVectorFromArg, cframe2.Position) + Vector3.new(
					0,
					cameraHeight,
					0
				)
			end
		else
			cframe2 = CFrame.new(subjectPosition)
			local position = cframe2.Position
			local newLookVectorFromArg = self:CalculateNewLookVectorFromArg(lookVector, v5)

			if userFlag then
				cframe3 = CFrame.lookAlong(position - v7 * newLookVectorFromArg, newLookVectorFromArg)
			else
				cframe3 = CFrame.new(position - v7 * newLookVectorFromArg, position)
			end
		end

		local cameraToggleOffset = self:GetCameraToggleOffset(p)
		focus = cframe2 + cameraToggleOffset
		cFrame = cframe3 + cameraToggleOffset
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

return object