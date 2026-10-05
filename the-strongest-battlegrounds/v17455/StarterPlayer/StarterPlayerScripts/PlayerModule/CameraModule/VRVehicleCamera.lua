local VRBaseCamera = require(script.Parent:WaitForChild("VRBaseCamera"))
require(script.Parent:WaitForChild("CameraInput"))
local CameraUtils = require(script.Parent:WaitForChild("CameraUtils"))
local ZoomController = require(script.Parent:WaitForChild("ZoomController"))
require(script.Parent:WaitForChild("VehicleCamera"))
local VehicleCameraCore = require(script.Parent.VehicleCamera:FindFirstChild("VehicleCameraCore"))
local VehicleCameraConfig = require(script.Parent.VehicleCamera:FindFirstChild("VehicleCameraConfig"))
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
game:GetService("VRService")
local localPlayer = Players.LocalPlayer
local spring = CameraUtils.Spring
local mapClamp = CameraUtils.mapClamp
local _ = CameraUtils.sanitizeAngle

-- equivalent calls inferred from this helper; original call sites unknown
local function pitchVelocity(subjectRotVelocity, subjectCFrame)
	return (math.abs((subjectCFrame.XVector:Dot(subjectRotVelocity))))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function yawVelocity(subjectRotVelocity, subjectCFrame)
	return (math.abs((subjectCFrame.YVector:Dot(subjectRotVelocity))))
end

local v = 0.016666666666666666
local object = setmetatable({}, VRBaseCamera)
object.__index = object

function object.new()
	local self = setmetatable(VRBaseCamera.new(), object)
	self:Reset()
	RunService.Stepped:Connect(function(_, dt)
		v = dt
	end)
	return self
end

function object:Reset()
	self.vehicleCameraCore = VehicleCameraCore.new(self:GetSubjectCFrame())
	self.pitchSpring = spring.new(0, -math.rad(VehicleCameraConfig.pitchBaseAngle))
	self.yawSpring = spring.new(0, 0)
	local currentCamera = workspace.CurrentCamera
	local cameraSubject = currentCamera and currentCamera.CameraSubject
	assert(currentCamera, "VRVehicleCamera initialization error")
	assert(cameraSubject)
	assert(cameraSubject:IsA("VehicleSeat"))
	local connectedParts = cameraSubject:GetConnectedParts(true)
	local looseBoundingSphere, v2 = CameraUtils.getLooseBoundingSphere(connectedParts)
	self.assemblyRadius = math.max(v2, 0.001)
	self.assemblyOffset = cameraSubject.CFrame:Inverse() * looseBoundingSphere
	self.lastCameraFocus = nil
	self:_StepInitialZoom()
end

function object:_StepInitialZoom()
	self:SetCameraToSubjectDistance((math.max(
		ZoomController.GetZoomRadius(),
		self.assemblyRadius * VehicleCameraConfig.initialZoomRadiusMul
	)))
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
	math.abs((subjectVelocity:Dot(subjectCFrame.ZVector)))
	local v3 = yawVelocity(subjectRotVelocity, subjectCFrame) -- equivalent call inferred; original call site unknown
	local v4 = pitchVelocity(subjectRotVelocity, subjectCFrame) -- equivalent call inferred; original call site unknown
	local v5 = self:StepZoom()
	local v6 = mapClamp(v5, 0.5, self.assemblyRadius, 1, 0)
	local lerped = self:_GetThirdPersonLocalOffset():Lerp(self:_GetFirstPersonLocalOffset(subjectCFrame), v6)
	vehicleCameraCore:setTransform(subjectCFrame)
	local v7 = vehicleCameraCore:step(v2, v4, v3, v6)
	self:UpdateFadeFromBlack(v2)
	local lastCameraFocus, cframe

	if self:IsInFirstPerson() then
		local unit = Vector3.new(v7.LookVector.X, 0, v7.LookVector.Z).Unit
		local cframe2 = CFrame.new(v7.Position, unit)
		lastCameraFocus = CFrame.new(subjectCFrame * lerped) * cframe2
		cframe = lastCameraFocus * CFrame.new(0, 0, v5)
		self:StartVREdgeBlur(localPlayer)
	else
		lastCameraFocus = CFrame.new(subjectCFrame * lerped) * v7
		cframe = lastCameraFocus * CFrame.new(0, 0, v5)

		if not self.lastCameraFocus then
			self.lastCameraFocus = lastCameraFocus
			self.needsReset = true
		end

		local v8 = lastCameraFocus.Position - currentCamera.CFrame.Position
		local magnitude = v8.magnitude

		if v8.Unit:Dot(currentCamera.CFrame.LookVector) > 0.56 and magnitude < 200 and not self.needsReset then
			lastCameraFocus = self.lastCameraFocus
			local p = lastCameraFocus.p
			local cameraLookVector = self:GetCameraLookVector()
			local newLookVectorFromArg = self:CalculateNewLookVectorFromArg(
				Vector3.new(cameraLookVector.X, 0, cameraLookVector.Z).Unit,
				Vector2.new(0, 0)
			)
			cframe = CFrame.new(p - v5 * newLookVectorFromArg, p)
		else
			self.currentSubjectDistance = 16
			self.lastCameraFocus = self:GetVRFocus(subjectCFrame.Position, v2)
			self.needsReset = false
			self:StartFadeFromBlack()
			self:ResetZoom()
		end

		self:UpdateEdgeBlur(localPlayer, v2)
	end

	return cframe, lastCameraFocus
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