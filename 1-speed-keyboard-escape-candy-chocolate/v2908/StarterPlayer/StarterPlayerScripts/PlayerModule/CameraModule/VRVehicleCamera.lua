local createVector = vector.create
local success, result = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserVRVehicleCameraOrbital")
end)
local v = success and result
local v2 = { 0, 30 }
local VRBaseCamera = require(script.Parent:WaitForChild("VRBaseCamera"))
local CameraUtils = require(script.Parent:WaitForChild("CameraUtils"))
local CameraInput = require(script.Parent:WaitForChild("CameraInput"))
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VRService = game:GetService("VRService")
local Lighting = game:GetService("Lighting")
local localPlayer = Players.LocalPlayer
local mapClamp = CameraUtils.mapClamp
local VehicleCameraConfig = require(script.Parent:WaitForChild("VehicleCamera"):FindFirstChild("VehicleCameraConfig"))
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.IgnoreWater = true

-- equivalent calls inferred from this helper; original call sites unknown
local function yawVelocity(subjectRotVelocity: Vector3, subjectCFrame: CFrame)
	return (math.abs((subjectCFrame.YVector:Dot(subjectRotVelocity))))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function computeCameraCFrame(cframe: CFrame, vector2: Vector3, p: number)
	local v3 = math.atan2(vector2.X, vector2.Z)
	return CFrame.new(cframe.Position + vector2 * p) * CFrame.Angles(0, v3, 0)
end

local function vrOccludeDisplace(cframe: CFrame, lastOrbitalDir: Vector3, cameraToSubjectDistance: number, vehicleModel)
	local cameraCFrame = computeCameraCFrame(cframe, lastOrbitalDir, cameraToSubjectDistance) -- equivalent call inferred; original call site unknown
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return cameraCFrame
	end

	local position = cframe.Position
	local v4 = (cameraCFrame.Position - position) * createVector(1, 0, 1)
	local magnitude = v4.Magnitude

	if magnitude < 0.5 then
		return cameraCFrame
	end

	local filterDescendantsInstances = { currentCamera }

	if vehicleModel then
		table.insert(filterDescendantsInstances, vehicleModel)
	end

	local character = localPlayer and localPlayer.Character

	if character then
		table.insert(filterDescendantsInstances, character)
	end

	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	local unit = v4.Unit
	local raycastResult = workspace:Raycast(position, v4, raycastParams)

	if raycastResult and raycastResult.Normal:Dot(unit) < 0 then
		local v6 = (raycastResult.Position - position).Magnitude - 0.5

		if v6 < magnitude then
			local v7 = math.max(v6, 0.5)
			return CFrame.new(cframe.Position + unit * v7) * cameraCFrame.Rotation
		end
	end

	return cameraCFrame
end

local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Exclude

local function findObstructions(cframe: CFrame, cframe2: CFrame, p: number, vehicleModel)
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return 0, {}
	end

	local position = cframe2.Position
	local userCFrame = VRService:GetUserCFrame(Enum.UserCFrame.Head)
	local headScale = currentCamera.HeadScale
	local v3 = cframe * (CFrame.new(userCFrame.Position * headScale) * userCFrame.Rotation)
	local v4 = v3.Position - position
	local magnitude = v4.Magnitude

	if magnitude < 0.5 then
		return 0, {}
	end

	local filterDescendantsInstances = { currentCamera }

	if vehicleModel then
		table.insert(filterDescendantsInstances, vehicleModel)
	end

	local character = localPlayer and localPlayer.Character

	if character then
		table.insert(filterDescendantsInstances, character)
	end

	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	local raycastResult = workspace:Raycast(position, v4, raycastParams)

	if raycastResult then
		local magnitude2 = (raycastResult.Position - position).Magnitude

		if magnitude2 < magnitude then
			local lookVector = v3.LookVector
			local v6 = math.max(
				math.clamp((1 - -v4.Unit:Dot(lookVector)) / 0.1339745962155613, 0, 1),
				1 - magnitude2 / p,
				0.15
			)
			local position2 = raycastResult.Position
			local position3 = v3.Position
			local midpoint = (position2 + position3) / 2
			local vector2 = Vector3.new(2, 2, (position3 - position2).Magnitude)
			local cframe3 = CFrame.lookAt(midpoint, position3)
			overlapParams.FilterDescendantsInstances = filterDescendantsInstances
			return v6, (workspace:GetPartBoundsInBox(cframe3, vector2, overlapParams))
		end
	end

	return 0, {}
end

local v3 = 0.016666666666666666
local object = setmetatable({}, VRBaseCamera)
object.__index = object

function object.new()
	if not v then
		local VRVehicleCameraDeprecated = require(script.Parent:WaitForChild("VRVehicleCameraDeprecated"))
		return VRVehicleCameraDeprecated.new()
	end

	local self = setmetatable(VRBaseCamera.new(), object)
	self.skipOcclusion = true
	self:Reset()

	if self.thirdPersonOptionChanged then
		self.thirdPersonOptionChanged:Disconnect()
		self.thirdPersonOptionChanged = nil
	end

	RunService.Stepped:Connect(function(_: number, dt: number)
		v3 = dt
	end)
	return self
end

function object:Reset()
	local currentCamera = workspace.CurrentCamera
	local cameraSubject = currentCamera and currentCamera.CameraSubject
	assert(currentCamera, "VRVehicleCamera initialization error")
	assert(cameraSubject)
	assert(cameraSubject:IsA("VehicleSeat"))
	self.lastOrbitalDir = nil
	self.wasInFirstPerson = nil
	local connectedParts = cameraSubject:GetConnectedParts(true)
	table.insert(connectedParts, cameraSubject)
	local looseBoundingSphere, v4 = CameraUtils.getLooseBoundingSphere(connectedParts)
	self.vehicleModel = cameraSubject:FindFirstAncestorOfClass("Model") or cameraSubject.Parent
	self.assemblyRadius = math.max(v4, 5)
	self.assemblyOffset = cameraSubject.CFrame:Inverse() * looseBoundingSphere
	self.gamepadZoomLevels = {}

	for _, v5 in v2 do
		table.insert(self.gamepadZoomLevels, v5 * self.headScale * self.assemblyRadius / 10)
	end

	self.lastCameraFocus = nil

	if not self:IsInFirstPerson() then
		self:SetCameraToSubjectDistance(self.gamepadZoomLevels[#self.gamepadZoomLevels])
	end

	self.needsReset = false
end

function object:_getThirdPersonLocalOffset()
	return self.assemblyOffset + Vector3.new(0, self.assemblyRadius * VehicleCameraConfig.verticalCenterOffset, 0)
end

function object:_getFirstPersonLocalOffset(cframe: CFrame)
	local character = localPlayer.Character

	if character and character.Parent then
		local head = character:FindFirstChild("Head")

		if head and head:IsA("BasePart") then
			return cframe:Inverse() * head.Position
		end
	end

	return self:_getThirdPersonLocalOffset()
end

function object:_vrOccludeVignette(cframe: CFrame, vector2: Vector3, p: number)
	local cameraCFrame = computeCameraCFrame(cframe, vector2, p) -- equivalent call inferred; original call site unknown
	local obstructions, lastOccludedParts = findObstructions(cameraCFrame, cframe, p, self.vehicleModel)
	local v6 = Lighting:FindFirstChild("VRFade")

	if not v6 then
		v6 = Instance.new("ColorCorrectionEffect")
		v6.Name = "VRFade"
		v6.Parent = Lighting
	end

	v6.Brightness = -obstructions

	if self.lastOccludedParts then
		for _, lastOccludedPart in self.lastOccludedParts do
			lastOccludedPart.LocalTransparencyModifier = 0
		end
	end

	if #lastOccludedParts > 0 then
		for _, v7 in lastOccludedParts do
			v7.LocalTransparencyModifier = 1
		end

		self:StartVREdgeBlur(localPlayer, true)
	end

	self.lastOccludedParts = lastOccludedParts
	return cameraCFrame
end

function object:Update()
	local v4 = v3
	v3 = 0
	self:UpdateFadeFromBlack(v4)
	self:UpdateEdgeBlur(localPlayer, v4)
	local _updateStepRotation, v5 = self:_updateStepRotation(v4)
	return _updateStepRotation, v5
end

function object:_updateStepRotation(p: number)
	local subjectCFrame = self:GetSubjectCFrame()
	local cameraToSubjectDistance = self:GetCameraToSubjectDistance()
	local v4 = mapClamp(cameraToSubjectDistance, 0.5, self.assemblyRadius, 1, 0)
	local v5 = subjectCFrame * self:_getThirdPersonLocalOffset():Lerp(
		self:_getFirstPersonLocalOffset(subjectCFrame),
		v4
	)
	local cframe = CFrame.new(v5 + Vector3.new(0, self:GetCameraHeight(), 0))

	if self.needsReset or self.recentered then
		self.lastOrbitalDir = nil
		self.needsReset = false
		self.recentered = false
	end

	local lastOrbitalDir = self.lastOrbitalDir

	if not lastOrbitalDir then
		lastOrbitalDir = (subjectCFrame.LookVector * createVector(-1, 0, -1)).Unit
		self:StartFadeFromBlack()
	end

	local v6 = (self:GetSubjectVelocity() * createVector(1, 0, 1)).Magnitude > 2

	if v6 then
		CameraInput.getRotation(p)
	else
		local rotation = self:getRotation(p)

		if math.abs(rotation) > 0 then
			lastOrbitalDir = (CFrame.Angles(0, -rotation, 0) * CFrame.new(lastOrbitalDir)).Position.Unit
			self.lastRotateTime = os.clock()
		end
	end

	local v7

	if self:IsInFirstPerson() then
		if not self.wasInFirstPerson or v6 then
			lastOrbitalDir = (subjectCFrame.LookVector * createVector(-1, 0, -1)).Unit
			self.wasInFirstPerson = true
		end

		local lastVehicleYaw = math.atan2(-subjectCFrame.LookVector.X, -subjectCFrame.LookVector.Z)

		if self.lastVehicleYaw then
			local v9 = (lastVehicleYaw - self.lastVehicleYaw + 3.141592653589793) % 6.283185307179586 - 3.141592653589793

			if math.abs(v9) > 0.001 then
				lastOrbitalDir = (CFrame.Angles(0, v9, 0) * CFrame.new(lastOrbitalDir)).Position.Unit
			end
		end

		self.lastVehicleYaw = lastVehicleYaw
		v7 = computeCameraCFrame(cframe, lastOrbitalDir, cameraToSubjectDistance)
	else
		self.wasInFirstPerson = false
		self.lastVehicleYaw = nil
		local v8 = self.lastRotateTime and os.clock() - self.lastRotateTime < VehicleCameraConfig.autocorrectDelay

		if v6 and not v8 then
			local unit = (subjectCFrame.LookVector * createVector(-1, 0, -1)).Unit
			local v9 = math.acos((math.clamp(lastOrbitalDir:Dot(unit), -1, 1)))
			local v10 = yawVelocity(self:GetSubjectRotVelocity(), subjectCFrame) -- equivalent call inferred; original call site unknown
			lastOrbitalDir = lastOrbitalDir:Lerp(
				unit,
				(math.min(0.01 + v9 / 3.141592653589793 * 0.05 + v10 * 0.02, 0.15))
			)
		end

		v7 = vrOccludeDisplace(cframe, lastOrbitalDir, cameraToSubjectDistance, self.vehicleModel)
	end

	self.lastOrbitalDir = lastOrbitalDir
	return v7, v7 * CFrame.new(0, 0, -cameraToSubjectDistance)
end

return object