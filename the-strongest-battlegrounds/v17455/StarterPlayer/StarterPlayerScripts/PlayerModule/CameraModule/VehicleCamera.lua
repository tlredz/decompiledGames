local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local BaseCamera = require(script.Parent:WaitForChild("BaseCamera"))
local CameraInput = require(script.Parent:WaitForChild("CameraInput"))
local CameraUtils = require(script.Parent:WaitForChild("CameraUtils"))
local ZoomController = require(script.Parent:WaitForChild("ZoomController"))
local VehicleCameraCore = require(script:WaitForChild("VehicleCameraCore"))
local VehicleCameraConfig = require(script:WaitForChild("VehicleCameraConfig"))
local localPlayer = Players.LocalPlayer
local _ = CameraUtils.map
local spring = CameraUtils.Spring
local mapClamp = CameraUtils.mapClamp
local sanitizeAngle = CameraUtils.sanitizeAngle

-- equivalent calls inferred from this helper; original call sites unknown
local function pitchVelocity(subjectRotVelocity, subjectCFrame)
	return (math.abs((subjectCFrame.XVector:Dot(subjectRotVelocity))))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function yawVelocity(subjectRotVelocity, subjectCFrame)
	return (math.abs((subjectCFrame.YVector:Dot(subjectRotVelocity))))
end

local v = 0.016666666666666666
RunService.Stepped:Connect(function(_, dt)
	v = dt
end)
local object = setmetatable({}, BaseCamera)
object.__index = object

function object.new()
	local self = setmetatable(BaseCamera.new(), object)
	self:Reset()
	return self
end

function object:Reset()
	self.vehicleCameraCore = VehicleCameraCore.new(self:GetSubjectCFrame())
	self.pitchSpring = spring.new(0, -math.rad(VehicleCameraConfig.pitchBaseAngle))
	self.yawSpring = spring.new(0, 0)
	self.lastPanTick = 0
	local currentCamera = workspace.CurrentCamera
	local cameraSubject = currentCamera and currentCamera.CameraSubject
	assert(currentCamera)
	assert(cameraSubject)
	assert(cameraSubject:IsA("VehicleSeat"))
	local connectedParts = cameraSubject:GetConnectedParts(true)
	local looseBoundingSphere, v2 = CameraUtils.getLooseBoundingSphere(connectedParts)
	self.assemblyRadius = math.max(v2, 0.001)
	self.assemblyOffset = cameraSubject.CFrame:Inverse() * looseBoundingSphere
	self:_StepInitialZoom()
end

function object:_StepInitialZoom()
	self:SetCameraToSubjectDistance((math.max(
		ZoomController.GetZoomRadius(),
		self.assemblyRadius * VehicleCameraConfig.initialZoomRadiusMul
	)))
end

function object:_StepRotation(p, p2)
	local yawSpring = self.yawSpring
	local pitchSpring = self.pitchSpring
	local rotation = CameraInput.getRotation(true)
	local v2 = -rotation.X
	local v3 = -rotation.Y
	yawSpring.pos = sanitizeAngle(yawSpring.pos + v2)
	pitchSpring.pos = sanitizeAngle((math.clamp(pitchSpring.pos + v3, -1.3962634015954636, 1.3962634015954636)))

	if CameraInput.getRotationActivated() then
		self.lastPanTick = os.clock()
	end

	local goal = -math.rad(VehicleCameraConfig.pitchBaseAngle)
	local pitchDeadzoneAngle = math.rad(VehicleCameraConfig.pitchDeadzoneAngle)

	if os.clock() - self.lastPanTick > VehicleCameraConfig.autocorrectDelay then
		local freq = mapClamp(
			p2,
			VehicleCameraConfig.autocorrectMinCarSpeed,
			VehicleCameraConfig.autocorrectMaxCarSpeed,
			0,
			VehicleCameraConfig.autocorrectResponse
		)
		yawSpring.freq = freq
		pitchSpring.freq = freq

		if yawSpring.freq < 0.001 then
			yawSpring.vel = 0
		end

		if pitchSpring.freq < 0.001 then
			pitchSpring.vel = 0
		end

		if math.abs((sanitizeAngle(goal - pitchSpring.pos))) <= pitchDeadzoneAngle then
			pitchSpring.goal = pitchSpring.pos
		else
			pitchSpring.goal = goal
		end
	else
		yawSpring.freq = 0
		yawSpring.vel = 0
		pitchSpring.freq = 0
		pitchSpring.vel = 0
		pitchSpring.goal = goal
	end

	return CFrame.fromEulerAnglesYXZ(pitchSpring:step(p), yawSpring:step(p), 0)
end

function object:_GetThirdPersonLocalOffset()
	return self.assemblyOffset + Vector3.new(0, self.assemblyRadius * VehicleCameraConfig.verticalCenterOffset, 0)
end

function object:_GetFirstPersonLocalOffset(cframe: CFrame)
	local character = localPlayer.Character

	if character and character.Parent then
		local head = character:FindFirstChild("Head")

		if head and head:IsA("BasePart") then
			return cframe:Inverse() * head.Position
		end
	end

	return self:_GetThirdPersonLocalOffset()
end

function object:Update()
	local currentCamera = workspace.CurrentCamera
	local cameraSubject = currentCamera and currentCamera.CameraSubject
	local vehicleCameraCore = self.vehicleCameraCore
	assert(currentCamera)
	assert(cameraSubject)
	assert(cameraSubject:IsA("VehicleSeat"))
	local v2 = v
	v = 0
	local subjectCFrame = self:GetSubjectCFrame()
	local subjectVelocity = self:GetSubjectVelocity()
	local subjectRotVelocity = self:GetSubjectRotVelocity()
	local v3 = math.abs((subjectVelocity:Dot(subjectCFrame.ZVector)))
	local v4 = yawVelocity(subjectRotVelocity, subjectCFrame) -- equivalent call inferred; original call site unknown
	local v5 = pitchVelocity(subjectRotVelocity, subjectCFrame) -- equivalent call inferred; original call site unknown
	local v6 = self:StepZoom()
	local _StepRotation = self:_StepRotation(v2, v3)
	local v7 = mapClamp(v6, 0.5, self.assemblyRadius, 1, 0)
	local lerped = self:_GetThirdPersonLocalOffset():Lerp(self:_GetFirstPersonLocalOffset(subjectCFrame), v7)
	vehicleCameraCore:setTransform(subjectCFrame)
	local v8 = vehicleCameraCore:step(v2, v5, v4, v7)
	local v9 = CFrame.new(subjectCFrame * lerped) * v8 * _StepRotation
	return v9 * CFrame.new(0, 0, v6), v9
end

function object.ApplyVRTransform(_) end

function object:EnterFirstPerson()
	self.inFirstPerson = true
	self:UpdateMouseBehavior()
end

function object:LeaveFirstPerson()
	self.inFirstPerson = false
	self:UpdateMouseBehavior()
end

return object