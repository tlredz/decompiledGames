local createVector = vector.create
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
local CameraInput = require(script.Parent:WaitForChild("CameraInput"))
local Players = game:GetService("Players")
local VRService = game:GetService("VRService")
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

function object:LoadOrCreateNumberValueParameter(name: string, className, callback)
	local instance = script:FindFirstChild(name)

	if instance and instance:isA(className) then
		self.externalProperties[name] = instance.Value
	else
		if self.externalProperties[name] == nil then
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
	local v = math.max(self.externalProperties.MinElevation, -80)
	local v2 = math.min(self.externalProperties.MaxElevation, 80)
	self.minElevationRad = math.rad((math.min(v, v2)))
	self.maxElevationRad = math.rad((math.max(v, v2)))
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

function object.SetInitialOrientation(object2, p)
	if not (p and p.RootPart) then
		warn("OrbitalCamera could not set initial orientation due to missing humanoid")
		return
	end

	assert(p.RootPart, "")
	local unit = (p.RootPart.CFrame.LookVector - createVector(0, 0.23, 0)).Unit
	local angleBetweenXZVectors = CameraUtils.GetAngleBetweenXZVectors(unit, object2:GetCameraLookVector())
	local v = math.asin(object2:GetCameraLookVector().Y) - math.asin(unit.Y)
	CameraUtils.IsFinite(angleBetweenXZVectors)
	CameraUtils.IsFinite(v)
end

function object.GetCameraToSubjectDistance(p)
	return p.curDistance
end

function object:SetCameraToSubjectDistance(value)
	if Players.LocalPlayer then
		self.currentSubjectDistance = math.clamp(value, self.minDistance, self.maxDistance)
		self.currentSubjectDistance = math.max(self.currentSubjectDistance, self.FIRST_PERSON_DISTANCE_THRESHOLD)
	end

	self.inFirstPerson = false
	self:UpdateMouseBehavior()
	return self.currentSubjectDistance
end

function object:CalculateNewLookVector(vector2: Vector3, point: Vector2)
	local v = vector2 or self:GetCameraLookVector()
	local v2 = math.asin(v.Y)
	local v3 = math.clamp(point.Y, v2 - 1.3962634015954636, v2 - -1.3962634015954636)
	local vector3 = Vector2.new(point.X, v3)
	local cframe = CFrame.new(createVector(0, 0, 0), v)
	return (CFrame.Angles(0, -vector3.X, 0) * cframe * CFrame.Angles(-vector3.Y, 0, 0)).LookVector
end

function object:Update(_: number)
	local now = tick()
	local v = now - self.lastUpdate
	local v2 = CameraInput.getRotation() ~= Vector2.new()
	local currentCamera = workspace.CurrentCamera
	local cFrame = currentCamera.CFrame
	local focus = currentCamera.Focus
	local localPlayer = Players.LocalPlayer
	local cameraSubject = currentCamera and currentCamera.CameraSubject
	local v3 = cameraSubject and cameraSubject:IsA("VehicleSeat")
	local v4 = cameraSubject and cameraSubject:IsA("SkateboardPlatform")

	if self.lastUpdate == nil or v > 1 then
		self.lastCameraTransform = nil
	end

	if v2 then
		self.lastUserPanCamera = tick()
	end

	local subjectPosition = self:GetSubjectPosition()

	if subjectPosition and localPlayer and currentCamera then
		if self.gamepadDollySpeedMultiplier ~= 1 then
			self:SetCameraToSubjectDistance(self.currentSubjectDistance * self.gamepadDollySpeedMultiplier)
		end

		local vREnabled = VRService.VREnabled
		focus = vREnabled and self:GetVRFocus(subjectPosition, v) or CFrame.new(subjectPosition)
		local rotation = CameraInput.getRotation()
		local p = focus.p

		if vREnabled and not self:IsInFirstPerson() then
			local cameraHeight = self:GetCameraHeight()
			local v5 = subjectPosition - currentCamera.CFrame.p
			local magnitude = v5.Magnitude

			if self.currentSubjectDistance < magnitude or rotation.X ~= 0 then
				local v6 = math.min(magnitude, self.currentSubjectDistance)
				local v7 = self:CalculateNewLookVector(v5.Unit * createVector(1, 0, 1), Vector2.new(rotation.X, 0)) * v6
				local v8 = p - v7
				local lookVector = currentCamera.CFrame.LookVector

				if rotation.X ~= 0 then
					lookVector = v7
				end

				local vector2 = Vector3.new(v8.X + lookVector.X, v8.Y, v8.Z + lookVector.Z)
				cFrame = CFrame.new(v8, vector2) + Vector3.new(0, cameraHeight, 0)
			end
		else
			self.curAzimuthRad -= rotation.X

			if self.useAzimuthLimits then
				self.curAzimuthRad = math.clamp(
					self.curAzimuthRad,
					self.minAzimuthAbsoluteRad,
					self.maxAzimuthAbsoluteRad
				)
			else
				self.curAzimuthRad = self.curAzimuthRad == 0 and 0 or math.sign(self.curAzimuthRad) * (math.abs(self.curAzimuthRad) % 6.283185307179586) or 0
			end

			self.curElevationRad = math.clamp(
				self.curElevationRad + rotation.Y,
				self.minElevationRad,
				self.maxElevationRad
			)
			local v5 = subjectPosition + self.currentSubjectDistance * (CFrame.fromEulerAnglesYXZ(
				-self.curElevationRad,
				self.curAzimuthRad,
				0
			) * createVector(0, 0, 1))
			cFrame = CFrame.new(v5, subjectPosition)
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