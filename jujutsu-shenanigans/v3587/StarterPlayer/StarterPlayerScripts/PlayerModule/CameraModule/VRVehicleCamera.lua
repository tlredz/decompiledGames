local createVector = vector.create
local success, result = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserVRVehicleCamera2")
end)
local v = success and result
local v2 = { 0, 30 }
local UserGameSettings = UserSettings():GetService("UserGameSettings")
local VRBaseCamera = require(script.Parent:WaitForChild("VRBaseCamera"))
local CameraInput = require(script.Parent:WaitForChild("CameraInput"))
local CameraUtils = require(script.Parent:WaitForChild("CameraUtils"))
require(script.Parent:WaitForChild("VehicleCamera"))
local VehicleCameraCore = require(script.Parent.VehicleCamera:FindFirstChild("VehicleCameraCore"))
local VehicleCameraConfig = require(script.Parent.VehicleCamera:FindFirstChild("VehicleCameraConfig"))
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VRService = game:GetService("VRService")
local localPlayer = Players.LocalPlayer
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

local v3 = 0.016666666666666666
local object = setmetatable({}, VRBaseCamera)
object.__index = object

function object.new()
	local self = setmetatable(VRBaseCamera.new(), object)
	self:Reset()
	RunService.Stepped:Connect(function(_, dt)
		v3 = dt
	end)
	return self
end

function object:Reset()
	self.vehicleCameraCore = VehicleCameraCore.new(self:GetSubjectCFrame())

	if v then
		self.pitchSpring = spring.new(0, 0)
	else
		self.pitchSpring = spring.new(0, -math.rad(VehicleCameraConfig.pitchBaseAngle))
	end

	self.yawSpring = spring.new(0, 0)

	if v then
		self.lastPanTick = 0
		self.currentDriftAngle = 0
		self.needsReset = true
	end

	local currentCamera = workspace.CurrentCamera
	local cameraSubject = currentCamera and currentCamera.CameraSubject
	assert(currentCamera, "VRVehicleCamera initialization error")
	assert(cameraSubject)
	assert(cameraSubject:IsA("VehicleSeat"))
	local connectedParts = cameraSubject:GetConnectedParts(true)
	local looseBoundingSphere, v4 = CameraUtils.getLooseBoundingSphere(connectedParts)
	self.assemblyRadius = math.max(v4, 5)
	self.assemblyOffset = cameraSubject.CFrame:Inverse() * looseBoundingSphere
	self.gamepadZoomLevels = {}

	for _, v5 in v2 do
		table.insert(self.gamepadZoomLevels, v5 * self.headScale * self.assemblyRadius / 10)
	end

	self.lastCameraFocus = nil
	self:SetCameraToSubjectDistance(self.gamepadZoomLevels[#self.gamepadZoomLevels])
end

function object:_StepRotation(p, p2)
	local yawSpring = self.yawSpring
	local pitchSpring = self.pitchSpring
	local v4 = -self:getRotation(p)
	yawSpring.pos = sanitizeAngle(yawSpring.pos + v4)
	pitchSpring.pos = sanitizeAngle((math.clamp(pitchSpring.pos, -1.3962634015954636, 1.3962634015954636)))

	if CameraInput.getRotationActivated() then
		self.lastPanTick = os.clock()
	end

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

		if math.abs((sanitizeAngle(0 - pitchSpring.pos))) <= pitchDeadzoneAngle then
			pitchSpring.goal = pitchSpring.pos
		else
			pitchSpring.goal = 0
		end
	else
		yawSpring.freq = 0
		yawSpring.vel = 0
		pitchSpring.freq = 0
		pitchSpring.vel = 0
		pitchSpring.goal = 0
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
	if not v then
		return self:UpdateComfortCamera()
	end

	local v4 = v3
	v3 = 0
	self:UpdateFadeFromBlack(v4)
	self:UpdateEdgeBlur(localPlayer, v4)

	if VRService.ThirdPersonFollowCamEnabled then
		local v5, v6 = self:UpdateStepRotation(v4)
		return v5, v6
	end

	local v5, v6 = self:UpdateComfortCamera(v4)
	return v5, v6
end

function object:addDrift(p, p2)
	local function NormalizeAngle(p3)
		local v4 = (p3 + 12.566370614359172) % 6.283185307179586

		if v4 > 3.141592653589793 then
			return v4 - 6.283185307179586
		end

		return v4
	end

	local currentCamera = workspace.CurrentCamera
	local cameraToSubjectDistance = self:GetCameraToSubjectDistance()
	local subjectVelocity = self:GetSubjectVelocity()
	local subjectCFrame = self:GetSubjectCFrame()
	require(localPlayer:WaitForChild("PlayerScripts").PlayerModule:WaitForChild("ControlModule"))

	if not (subjectVelocity.Magnitude > 0.1) then
		return p, p2
	end

	local userCFrame = VRService:GetUserCFrame(Enum.UserCFrame.Head)
	local v4 = userCFrame.Rotation + userCFrame.Position * currentCamera.HeadScale
	local cframe = currentCamera.CFrame * v4
	local _, v5, _ = cframe:ToEulerAnglesYXZ()
	local _, v6, _ = subjectCFrame:ToEulerAnglesYXZ()
	local v7 = (v5 - self.currentDriftAngle + 12.566370614359172) % 6.283185307179586

	if v7 > 3.141592653589793 then
		v7 -= 6.283185307179586
	end

	local v8 = (v6 - self.currentDriftAngle + 12.566370614359172) % 6.283185307179586

	if v8 > 3.141592653589793 then
		v8 -= 6.283185307179586
	end

	local v9 = math.min(v8, v7)
	local v10 = math.max(v8, v7)
	local v11 = 0

	if v9 > 0 then
		v11 = v9
	elseif v10 < 0 then
		v11 = v10
	end

	self.currentDriftAngle = v11 + self.currentDriftAngle
	local lookVector = CFrame.fromEulerAnglesYXZ(0, self.currentDriftAngle, 0).LookVector
	local v12 = Vector3.new(lookVector.X, 0, lookVector.Z).Unit * cameraToSubjectDistance
	local v13 = p2.Position - v12
	p = p:Lerp(CFrame.new(currentCamera.CFrame.Position + v13 - cframe.Position) * currentCamera.CFrame.Rotation, 0.01)
	return p, p2
end

function object:UpdateRotationCamera(p)
	local currentCamera = workspace.CurrentCamera
	local cameraSubject = currentCamera and currentCamera.CameraSubject
	local vehicleCameraCore = self.vehicleCameraCore
	assert(currentCamera)
	assert(cameraSubject)
	assert(cameraSubject:IsA("VehicleSeat"))
	local subjectCFrame = self:GetSubjectCFrame()
	local subjectVelocity = self:GetSubjectVelocity()
	local subjectRotVelocity = self:GetSubjectRotVelocity()
	local v4 = math.abs((subjectVelocity:Dot(subjectCFrame.ZVector)))
	local v5 = yawVelocity(subjectRotVelocity, subjectCFrame) -- equivalent call inferred; original call site unknown
	local v6 = pitchVelocity(subjectRotVelocity, subjectCFrame) -- equivalent call inferred; original call site unknown
	local cameraToSubjectDistance = self:GetCameraToSubjectDistance()
	local v7 = mapClamp(cameraToSubjectDistance, 0.5, self.assemblyRadius, 1, 0)
	local lerped = self:_GetThirdPersonLocalOffset():Lerp(self:_GetFirstPersonLocalOffset(subjectCFrame), v7)
	vehicleCameraCore:setTransform(subjectCFrame)
	local v8 = vehicleCameraCore:step(p, v6, v5, v7)
	local _StepRotation = self:_StepRotation(p, v4)
	local v9 = self:GetVRFocus(subjectCFrame * lerped, p) * v8 * _StepRotation
	local v10 = v9 * CFrame.new(0, 0, cameraToSubjectDistance)

	if subjectVelocity.Magnitude > 0.1 then
		self:StartVREdgeBlur(localPlayer)
	end

	return v10, v9
end

function object:UpdateStepRotation(p)
	local currentCamera = workspace.CurrentCamera
	local lastSubjectCFrame = self.lastSubjectCFrame
	local subjectCFrame = self:GetSubjectCFrame()
	local subjectVelocity = self:GetSubjectVelocity()
	local cameraToSubjectDistance = self:GetCameraToSubjectDistance()
	local v4 = mapClamp(cameraToSubjectDistance, 0.5, self.assemblyRadius, 1, 0)
	local lerped = self:_GetThirdPersonLocalOffset():Lerp(self:_GetFirstPersonLocalOffset(subjectCFrame), v4)
	local vRFocus = self:GetVRFocus(subjectCFrame * lerped, p)
	local v5, cframe = self:addDrift(
		vRFocus:ToWorldSpace(self:GetVRFocus(lastSubjectCFrame * lerped, p):ToObjectSpace(currentCamera.CFrame)),
		vRFocus
	)
	local rotation = self:getRotation(p)
	local selected

	if math.abs(rotation) > 0 then
		local objectSpace = cframe:ToObjectSpace(v5)
		selected = cframe * CFrame.Angles(0, -rotation, 0) * objectSpace

		if not UserGameSettings.VRSmoothRotationEnabled then
			local userCFrame = VRService:GetUserCFrame(Enum.UserCFrame.Head)
			local v7 = userCFrame.Rotation + userCFrame.Position * currentCamera.HeadScale
			local cframe2 = cframe * subjectCFrame.Rotation
			local objectSpace2 = cframe2:ToObjectSpace(v5 * v7)
			local v8 = math.acos((Vector3.new(objectSpace2.X, 0, objectSpace2.Z).Unit:Dot(createVector(0, 0, 1))))
			local objectSpace3 = cframe2:ToObjectSpace(selected * v7)

			if math.acos((Vector3.new(objectSpace3.X, 0, objectSpace3.Z).Unit:Dot(createVector(0, 0, 1)))) < v8 then
				if rotation < 0 then
					v8 *= -1
				end

				selected = cframe * CFrame.Angles(0, -v8, 0) * objectSpace
			end
		end
	else
		selected = v5
	end

	if subjectVelocity.Magnitude > 0.1 then
		self:StartVREdgeBlur(localPlayer)
	end

	if self.needsReset then
		self.needsReset = false
		VRService:RecenterUserHeadCFrame()
		self:StartFadeFromBlack()
		self:ResetZoom()
	end

	if self.recentered then
		selected = cframe * subjectCFrame.Rotation * CFrame.new(0, 0, cameraToSubjectDistance)
		self.recentered = false
	end

	return selected, selected * CFrame.new(0, 0, -cameraToSubjectDistance)
end

function object:UpdateComfortCamera(p)
	local currentCamera = workspace.CurrentCamera
	local cameraSubject = currentCamera and currentCamera.CameraSubject
	local vehicleCameraCore = self.vehicleCameraCore
	assert(currentCamera)
	assert(cameraSubject)
	assert(cameraSubject:IsA("VehicleSeat"))

	if not v then
		p = v3
		v3 = 0
	end

	local subjectCFrame = self:GetSubjectCFrame()
	local subjectVelocity = self:GetSubjectVelocity()
	local subjectRotVelocity = self:GetSubjectRotVelocity()
	math.abs((subjectVelocity:Dot(subjectCFrame.ZVector)))
	local v4 = yawVelocity(subjectRotVelocity, subjectCFrame) -- equivalent call inferred; original call site unknown
	local v5 = pitchVelocity(subjectRotVelocity, subjectCFrame) -- equivalent call inferred; original call site unknown
	local v6 = self:StepZoom()
	local v7 = mapClamp(v6, 0.5, self.assemblyRadius, 1, 0)
	local lerped = self:_GetThirdPersonLocalOffset():Lerp(self:_GetFirstPersonLocalOffset(subjectCFrame), v7)
	vehicleCameraCore:setTransform(subjectCFrame)
	local v8 = vehicleCameraCore:step(p, v5, v4, v7)

	if not v then
		self:UpdateFadeFromBlack(p)
	end

	local lastCameraFocus, cframe

	if self:IsInFirstPerson() then
		local unit = Vector3.new(v8.LookVector.X, 0, v8.LookVector.Z).Unit
		local cframe2 = CFrame.new(v8.Position, unit)
		lastCameraFocus = CFrame.new(subjectCFrame * lerped) * cframe2
		cframe = lastCameraFocus * CFrame.new(0, 0, v6)

		if v then
			if subjectVelocity.Magnitude > 0.1 then
				self:StartVREdgeBlur(localPlayer)
			end
		else
			self:StartVREdgeBlur(localPlayer)
		end
	else
		lastCameraFocus = CFrame.new(subjectCFrame * lerped) * v8
		cframe = lastCameraFocus * CFrame.new(0, 0, v6)

		if not self.lastCameraFocus then
			self.lastCameraFocus = lastCameraFocus
			self.needsReset = true
		end

		local v9 = lastCameraFocus.Position - currentCamera.CFrame.Position
		local magnitude = v9.magnitude

		if v9.Unit:Dot(currentCamera.CFrame.LookVector) > 0.56 and magnitude < 200 and not self.needsReset then
			lastCameraFocus = self.lastCameraFocus
			local p2 = lastCameraFocus.p
			local cameraLookVector = self:GetCameraLookVector()
			local newLookVectorFromArg = self:CalculateNewLookVectorFromArg(
				Vector3.new(cameraLookVector.X, 0, cameraLookVector.Z).Unit,
				Vector2.new(0, 0)
			)
			cframe = CFrame.new(p2 - v6 * newLookVectorFromArg, p2)
		else
			self.lastCameraFocus = self:GetVRFocus(subjectCFrame.Position, p)
			self.needsReset = false
			self:StartFadeFromBlack()
			self:ResetZoom()
		end

		if not v then
			self:UpdateEdgeBlur(localPlayer, p)
		end
	end

	return cframe, lastCameraFocus
end

return object