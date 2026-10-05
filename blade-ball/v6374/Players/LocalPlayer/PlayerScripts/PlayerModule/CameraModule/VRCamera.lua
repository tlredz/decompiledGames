local createVector = vector.create
local Players = game:GetService("Players")
local VRService = game:GetService("VRService")
local UserGameSettings = UserSettings():GetService("UserGameSettings")
local CameraInput = require(script.Parent:WaitForChild("CameraInput"))
require(script.Parent:WaitForChild("CameraUtils"))
local success, result = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserVRRotationUpdate")
end)
local v = success and result
local VRBaseCamera = require(script.Parent:WaitForChild("VRBaseCamera"))
local object = setmetatable({}, VRBaseCamera)
object.__index = object

function object.new()
	local self = setmetatable(VRBaseCamera.new(), object)
	self.lastUpdate = tick()
	self:Reset()
	return self
end

function object:Reset()
	self.needsReset = true
	self.needsBlackout = true
	self.motionDetTime = 0
	self.blackOutTimer = 0
	self.lastCameraResetPosition = nil

	if v then
		VRBaseCamera.Reset(self)
		return
	end

	self.stepRotateTimeout = 0
	self.cameraOffsetRotation = 0
	self.cameraOffsetRotationDiscrete = 0
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
		local v2 = math.clamp(value, 0.0001, 0.1)
		self.blackOutTimer += v2

		if self.blackOutTimer > 0.1 and game:IsLoaded() then
			self.needsBlackout = false
			self.needsReset = true
		end
	end

	if subjectPosition and localPlayer and currentCamera then
		local vRFocus = self:GetVRFocus(subjectPosition, value)

		if self:IsInFirstPerson() then
			cFrame, focus = self:UpdateFirstPersonTransform(
				value,
				cFrame,
				vRFocus,
				lastSubjectPosition,
				subjectPosition
			)
		else
			cFrame, focus = self:UpdateThirdPersonTransform(
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

		if not v then
			self.stepRotateTimeout = 0.25
			self.VRCameraFocusFrozen = true
			self.cameraOffsetRotation = 0
			self.cameraOffsetRotationDiscrete = 0
		end
	end

	local localPlayer = Players.LocalPlayer

	if (p3 - p4).magnitude > 0.01 then
		self:StartVREdgeBlur(localPlayer)
	end

	local p5 = p2.p
	local cameraLookVector = self:GetCameraLookVector()
	local unit = Vector3.new(cameraLookVector.X, 0, cameraLookVector.Z).Unit
	local X

	if v then
		X = self:getRotation(p)
	else
		if self.stepRotateTimeout > 0 then
			self.stepRotateTimeout -= p
		end

		local rotation = CameraInput.getRotation()
		X = 0

		if UserGameSettings.VRSmoothRotationEnabled then
			X = rotation.X
		elseif self.stepRotateTimeout <= 0 and math.abs(rotation.X) > 0.03 then
			X = rotation.X < 0 and -0.5 or 0.5
			self.needsReset = true
		end
	end

	local newLookVectorFromArg = self:CalculateNewLookVectorFromArg(unit, Vector2.new(X, 0))
	return CFrame.new(p5 - 0.5 * newLookVectorFromArg, p5), p2
end

function object:UpdateThirdPersonTransform(p, cframe, cframe2, p2, lastCameraResetPosition)
	local cameraToSubjectDistance = self:GetCameraToSubjectDistance()
	local v2 = cameraToSubjectDistance < 0.5 and 0.5 or cameraToSubjectDistance

	if p2 == nil or self.lastCameraFocus == nil then
		return cframe, cframe2
	end

	local localPlayer = Players.LocalPlayer
	local v3 = p2 - lastCameraResetPosition
	local ControlModule = require(localPlayer:WaitForChild("PlayerScripts").PlayerModule:WaitForChild("ControlModule"))
	local moveVector = ControlModule:GetMoveVector()
	local v4 = v3.magnitude > 0.01 or moveVector.magnitude > 0.01

	if v4 then
		self.motionDetTime = 0.1
	end

	self.motionDetTime -= p

	if (self.motionDetTime > 0 or v4) and not self.needsReset then
		local lastCameraFocus = self.lastCameraFocus
		self.VRCameraFocusFrozen = true
		return cframe, lastCameraFocus
	else
		local v5 = self.lastCameraResetPosition == nil or (lastCameraResetPosition - self.lastCameraResetPosition).Magnitude > 1

		if v then
			local rotation = self:getRotation(p)

			if math.abs(rotation) > 0 then
				local objectSpace = cframe2:ToObjectSpace(cframe)
				cframe = cframe2 * CFrame.Angles(0, rotation, 0) * objectSpace
			end

			if not (self.VRCameraFocusFrozen and v5 or self.needsReset) then
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
			local v6 = cframe2.Position - vector2 * v2
			local vector3 = Vector3.new(cframe2.Position.X, v6.Y, cframe2.Position.Z)
			return CFrame.new(v6, vector3), cframe2
		else
			local rotation = CameraInput.getRotation()
			local v6 = false

			if rotation ~= Vector2.new() and rotation.X ~= 0 then
				local v7 = self.cameraOffsetRotation + rotation.X

				if v7 < -3.141592653589793 then
					local v8 = v7 + 3.141592653589793
					v7 = 3.141592653589793 - v8
				elseif v7 > 3.141592653589793 then
					v7 = -3.141592653589793 + (v7 - 3.141592653589793)
				end

				self.cameraOffsetRotation = math.clamp(v7, -3.141592653589793, 3.141592653589793)

				if UserGameSettings.VRSmoothRotationEnabled then
					self.cameraOffsetRotationDiscrete = self.cameraOffsetRotation
					local humanoid = self:GetHumanoid()
					local lookVector = humanoid.Torso and humanoid.Torso.CFrame.lookVector or createVector(1, 0, 0)
					local vector2 = Vector3.new(lookVector.X, 0, lookVector.Z)
					local v8 = cframe2.Position - vector2 * v2
					local vector3 = Vector3.new(cframe2.Position.X, v8.Y, cframe2.Position.Z)
					local v9 = vector3 - (CFrame.new(v8, vector3) * CFrame.fromAxisAngle(
						createVector(0, 1, 0),
						self.cameraOffsetRotationDiscrete
					)).LookVector * (vector3 - v8).Magnitude
					cframe = CFrame.new(v9, vector3)
				else
					local cameraOffsetRotationDiscrete = math.floor(self.cameraOffsetRotation * 12 / 12)

					if cameraOffsetRotationDiscrete ~= self.cameraOffsetRotationDiscrete then
						self.cameraOffsetRotationDiscrete = cameraOffsetRotationDiscrete
						v6 = true
					end
				end
			end

			if not (self.VRCameraFocusFrozen and v5 or self.needsReset or v6) then
				return cframe, cframe2
			end

			if not v6 then
				self.cameraOffsetRotationDiscrete = 0
				self.cameraOffsetRotation = 0
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
			local v7 = cframe2.Position - vector2 * v2
			local vector3 = Vector3.new(cframe2.Position.X, v7.Y, cframe2.Position.Z)

			if self.cameraOffsetRotation ~= 0 then
				v7 = vector3 - (CFrame.new(v7, vector3) * CFrame.fromAxisAngle(
					createVector(0, 1, 0),
					self.cameraOffsetRotationDiscrete
				)).LookVector * (vector3 - v7).Magnitude
			end

			cframe = CFrame.new(v7, vector3)
			return cframe, cframe2
		end
	end
end

function object:EnterFirstPerson()
	self.inFirstPerson = true
	self:UpdateMouseBehavior()
end

function object:LeaveFirstPerson()
	self.inFirstPerson = false
	self.needsReset = true
	self:UpdateMouseBehavior()

	if self.VRBlur then
		self.VRBlur.Visible = false
	end
end

return object