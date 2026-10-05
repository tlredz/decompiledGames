local createVector = vector.create
local vector2 = Vector2.new(0, 0)
local v = 0
local _ = {
	InitialDistance = 25,
	MinDistance = 10,
	MaxDistance = 100,
	InitialElevation = 35,
	MinElevation = 35,
	MaxElevation = 35,
	ReferenceAzimuth = -45,
	CWAzimuthTravel = 90,
	CCWAzimuthTravel = 90,
	UseAzimuthLimits = false
}
local CameraUtils = require(script.Parent:WaitForChild("CameraUtils"))
local Players = game:GetService("Players")
local VRService = game:GetService("VRService")

local function GetValueObject(childName, p)
	local child = script:FindFirstChild(childName)

	if child then
		return child.Value
	end

	return p
end

local BaseCamera = require(script.Parent:WaitForChild("BaseCamera"))
local object = setmetatable({}, BaseCamera)
object.__index = object

function object.new()
	local self = setmetatable(BaseCamera.new(), object)
	self.lastUpdate = tick()
	self.changedSignalConnections = {}
	self.refAzimuthRad = nil
	self.curAzimuthRad = nil
	self.minAzimuthAbsoluteRad = nil
	self.maxAzimuthAbsoluteRad = nil
	self.useAzimuthLimits = nil
	self.curElevationRad = nil
	self.minElevationRad = nil
	self.maxElevationRad = nil
	self.curDistance = nil
	self.minDistance = nil
	self.maxDistance = nil
	self.r3ButtonDown = false
	self.l3ButtonDown = false
	self.gamepadDollySpeedMultiplier = 1
	self.lastUserPanCamera = tick()
	self.externalProperties = {}
	self.externalProperties.InitialDistance = 25
	self.externalProperties.MinDistance = 10
	self.externalProperties.MaxDistance = 100
	self.externalProperties.InitialElevation = 35
	self.externalProperties.MinElevation = 35
	self.externalProperties.MaxElevation = 35
	self.externalProperties.ReferenceAzimuth = -45
	self.externalProperties.CWAzimuthTravel = 90
	self.externalProperties.CCWAzimuthTravel = 90
	self.externalProperties.UseAzimuthLimits = false
	self:LoadNumberValueParameters()
	return self
end

function object:LoadOrCreateNumberValueParameter(name, className, callback)
	local instance = script:FindFirstChild(name)

	if instance and instance:isA(className) then
		self.externalProperties[name] = instance.Value
	else
		if self.externalProperties[name] == nil then
			print("externalProperties table has no entry for ", name)
			return
		end

		instance = Instance.new(className)
		instance.Name = name
		instance.Parent = script
		instance.Value = self.externalProperties[name]
	end

	if callback then
		if self.changedSignalConnections[name] then
			self.changedSignalConnections[name]:Disconnect()
		end

		self.changedSignalConnections[name] = instance.Changed:Connect(function(p2)
			self.externalProperties[name] = p2
			callback(self)
		end)
	end
end

function object:SetAndBoundsCheckAzimuthValues()
	self.minAzimuthAbsoluteRad = math.rad(self.externalProperties.ReferenceAzimuth) - math.abs((math.rad(self.externalProperties.CWAzimuthTravel)))
	self.maxAzimuthAbsoluteRad = math.rad(self.externalProperties.ReferenceAzimuth) + math.abs((math.rad(self.externalProperties.CCWAzimuthTravel)))
	self.useAzimuthLimits = self.externalProperties.UseAzimuthLimits

	if self.useAzimuthLimits then
		self.curAzimuthRad = math.max(self.curAzimuthRad, self.minAzimuthAbsoluteRad)
		self.curAzimuthRad = math.min(self.curAzimuthRad, self.maxAzimuthAbsoluteRad)
	end
end

function object:SetAndBoundsCheckElevationValues()
	local v2 = math.max(self.externalProperties.MinElevation, -80)
	local v3 = math.min(self.externalProperties.MaxElevation, 80)
	self.minElevationRad = math.rad((math.min(v2, v3)))
	self.maxElevationRad = math.rad((math.max(v2, v3)))
	self.curElevationRad = math.max(self.curElevationRad, self.minElevationRad)
	self.curElevationRad = math.min(self.curElevationRad, self.maxElevationRad)
end

function object:SetAndBoundsCheckDistanceValues()
	self.minDistance = self.externalProperties.MinDistance
	self.maxDistance = self.externalProperties.MaxDistance
	self.curDistance = math.max(self.curDistance, self.minDistance)
	self.curDistance = math.min(self.curDistance, self.maxDistance)
end

function object:LoadNumberValueParameters()
	self:LoadOrCreateNumberValueParameter("InitialElevation", "NumberValue", nil)
	self:LoadOrCreateNumberValueParameter("InitialDistance", "NumberValue", nil)
	self:LoadOrCreateNumberValueParameter("ReferenceAzimuth", "NumberValue", self.SetAndBoundsCheckAzimuthValue)
	self:LoadOrCreateNumberValueParameter("CWAzimuthTravel", "NumberValue", self.SetAndBoundsCheckAzimuthValues)
	self:LoadOrCreateNumberValueParameter("CCWAzimuthTravel", "NumberValue", self.SetAndBoundsCheckAzimuthValues)
	self:LoadOrCreateNumberValueParameter("MinElevation", "NumberValue", self.SetAndBoundsCheckElevationValues)
	self:LoadOrCreateNumberValueParameter("MaxElevation", "NumberValue", self.SetAndBoundsCheckElevationValues)
	self:LoadOrCreateNumberValueParameter("MinDistance", "NumberValue", self.SetAndBoundsCheckDistanceValues)
	self:LoadOrCreateNumberValueParameter("MaxDistance", "NumberValue", self.SetAndBoundsCheckDistanceValues)
	self:LoadOrCreateNumberValueParameter("UseAzimuthLimits", "BoolValue", self.SetAndBoundsCheckAzimuthValues)
	self.curAzimuthRad = math.rad(self.externalProperties.ReferenceAzimuth)
	self.curElevationRad = math.rad(self.externalProperties.InitialElevation)
	self.curDistance = self.externalProperties.InitialDistance
	self:SetAndBoundsCheckAzimuthValues()
	self:SetAndBoundsCheckElevationValues()
	self:SetAndBoundsCheckDistanceValues()
end

function object.GetModuleName(_)
	return "OrbitalCamera"
end

function object:SetInitialOrientation(p)
	if not (p and p.RootPart) then
		warn("OrbitalCamera could not set initial orientation due to missing humanoid")
		return
	end

	local unit = (p.RootPart.CFrame.lookVector - createVector(0, 0.23, 0)).unit
	local angleBetweenXZVectors = CameraUtils.GetAngleBetweenXZVectors(unit, self:GetCameraLookVector())
	local v2 = math.asin(self:GetCameraLookVector().y) - math.asin(unit.y)
	local v3 = not CameraUtils.IsFinite(angleBetweenXZVectors) and 0 or angleBetweenXZVectors
	local v4 = not CameraUtils.IsFinite(v2) and 0 or v2
	self.rotateInput = Vector2.new(v3, v4)
end

function object.GetCameraToSubjectDistance(p)
	return p.curDistance
end

function object:SetCameraToSubjectDistance(p)
	print("OrbitalCamera SetCameraToSubjectDistance ", p)

	if Players.LocalPlayer then
		self.currentSubjectDistance = CameraUtils.Clamp(self.minDistance, self.maxDistance, p)
		self.currentSubjectDistance = math.max(self.currentSubjectDistance, self.FIRST_PERSON_DISTANCE_THRESHOLD)
	end

	self.inFirstPerson = false
	self:UpdateMouseBehavior()
	return self.currentSubjectDistance
end

function object:CalculateNewLookVector(p, p2)
	local v2 = p or self:GetCameraLookVector()
	local v3 = math.asin(v2.y)
	local clamped = CameraUtils.Clamp(v3 - 1.3962634015954636, v3 - -1.3962634015954636, p2.y)
	local vector3 = Vector2.new(p2.x, clamped)
	local cframe = CFrame.new(createVector(0, 0, 0), v2)
	return (CFrame.Angles(0, -vector3.x, 0) * cframe * CFrame.Angles(-vector3.y, 0, 0)).lookVector
end

function object:GetGamepadPan(_, p, data)
	if data.UserInputType ~= self.activeGamepad or data.KeyCode ~= Enum.KeyCode.Thumbstick2 then
		return Enum.ContextActionResult.Pass
	end

	if self.r3ButtonDown or self.l3ButtonDown then
		if data.Position.Y > 0.2 then
			self.gamepadDollySpeedMultiplier = 0.96
		elseif data.Position.Y < -0.2 then
			self.gamepadDollySpeedMultiplier = 1.04
		else
			self.gamepadDollySpeedMultiplier = 1
		end
	else
		if p == Enum.UserInputState.Cancel then
			self.gamepadPanningCamera = vector2
			return
		end

		if Vector2.new(data.Position.X, -data.Position.Y).magnitude > 0.2 then
			self.gamepadPanningCamera = Vector2.new(data.Position.X, -data.Position.Y)
		else
			self.gamepadPanningCamera = vector2
		end
	end

	return Enum.ContextActionResult.Sink
end

function object:DoGamepadZoom(_, p, p2)
	if p2.UserInputType ~= self.activeGamepad or p2.KeyCode ~= Enum.KeyCode.ButtonR3 and p2.KeyCode ~= Enum.KeyCode.ButtonL3 then
		return Enum.ContextActionResult.Pass
	end

	if p == Enum.UserInputState.Begin then
		self.r3ButtonDown = p2.KeyCode == Enum.KeyCode.ButtonR3
		self.l3ButtonDown = p2.KeyCode == Enum.KeyCode.ButtonL3
	elseif p == Enum.UserInputState.End then
		if p2.KeyCode == Enum.KeyCode.ButtonR3 then
			self.r3ButtonDown = false
		elseif p2.KeyCode == Enum.KeyCode.ButtonL3 then
			self.l3ButtonDown = false
		end

		if not (self.r3ButtonDown or self.l3ButtonDown) then
			self.gamepadDollySpeedMultiplier = 1
		end
	end

	return Enum.ContextActionResult.Sink
end

function object.BindGamepadInputActions(_) end

function object:Update(_)
	local now = tick()
	local v2 = now - self.lastUpdate
	local userPanningTheCamera = self.UserPanningTheCamera == true
	local currentCamera = workspace.CurrentCamera
	local cFrame = currentCamera.CFrame
	local focus = currentCamera.Focus
	local localPlayer = Players.LocalPlayer
	self:GetHumanoid()
	local cameraSubject = currentCamera and currentCamera.CameraSubject
	local v3 = cameraSubject and cameraSubject:IsA("VehicleSeat")
	local v4 = cameraSubject and cameraSubject:IsA("SkateboardPlatform")

	if self.lastUpdate == nil or v2 > 1 then
		self.lastCameraTransform = nil
	end

	if self.lastUpdate then
		local v5 = self:UpdateGamepad()

		if self:ShouldUseVRRotation() then
			self.RotateInput += self:GetVRRotationInput()
		else
			local v6 = math.min(0.1, v2)

			if v5 ~= vector2 then
				self.rotateInput += v5 * v6
				userPanningTheCamera = true
			end

			local v7 = 0

			if not (v3 or v4) then
				v7 = v7 + (self.TurningLeft and -120 or 0) + (self.TurningRight and 120 or 0)
			end

			if v7 ~= 0 then
				self.rotateInput += Vector2.new(math.rad(v7 * v6), 0)
				userPanningTheCamera = true
			end
		end
	end

	if userPanningTheCamera then
		v = 0
		self.lastUserPanCamera = tick()
	end

	local _ = now - self.lastUserPanCamera < 2
	local subjectPosition = self:GetSubjectPosition()

	if subjectPosition and localPlayer and currentCamera then
		if self.gamepadDollySpeedMultiplier ~= 1 then
			self:SetCameraToSubjectDistance(self.currentSubjectDistance * self.gamepadDollySpeedMultiplier)
		end

		local vREnabled = VRService.VREnabled
		focus = vREnabled and self:GetVRFocus(subjectPosition, v2) or CFrame.new(subjectPosition)
		local p = focus.p

		if vREnabled and not self:IsInFirstPerson() then
			local cameraHeight = self:GetCameraHeight()
			local v5 = subjectPosition - currentCamera.CFrame.p
			local magnitude = v5.magnitude

			if self.currentSubjectDistance < magnitude or self.rotateInput.x ~= 0 then
				local v6 = math.min(magnitude, self.currentSubjectDistance)
				local v7 = self:CalculateNewLookVector(
					v5.unit * createVector(1, 0, 1),
					Vector2.new(self.rotateInput.x, 0)
				) * v6
				local v8 = p - v7
				local lookVector = currentCamera.CFrame.lookVector

				if self.rotateInput.x ~= 0 then
					lookVector = v7
				end

				local vector3 = Vector3.new(v8.x + lookVector.x, v8.y, v8.z + lookVector.z)
				self.RotateInput = vector2
				cFrame = CFrame.new(v8, vector3) + Vector3.new(0, cameraHeight, 0)
			end
		else
			self.curAzimuthRad -= self.rotateInput.x

			if self.useAzimuthLimits then
				self.curAzimuthRad = CameraUtils.Clamp(
					self.minAzimuthAbsoluteRad,
					self.maxAzimuthAbsoluteRad,
					self.curAzimuthRad
				)
			else
				self.curAzimuthRad = self.curAzimuthRad == 0 and 0 or math.sign(self.curAzimuthRad) * (math.abs(self.curAzimuthRad) % 6.283185307179586) or 0
			end

			self.curElevationRad = CameraUtils.Clamp(
				self.minElevationRad,
				self.maxElevationRad,
				self.curElevationRad + self.rotateInput.y
			)
			local v5 = subjectPosition + self.currentSubjectDistance * (CFrame.fromEulerAnglesYXZ(
				-self.curElevationRad,
				self.curAzimuthRad,
				0
			) * createVector(0, 0, 1))
			cFrame = CFrame.new(v5, subjectPosition)
			self.rotateInput = vector2
		end

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

return object