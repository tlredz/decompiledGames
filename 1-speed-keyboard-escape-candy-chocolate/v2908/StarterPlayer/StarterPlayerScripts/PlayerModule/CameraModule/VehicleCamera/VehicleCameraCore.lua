local CameraUtils = require(script.Parent.Parent.CameraUtils)
local VehicleCameraConfig = require(script.Parent.VehicleCameraConfig)
local map = CameraUtils.map
local mapClamp = CameraUtils.mapClamp
local sanitizeAngle = CameraUtils.sanitizeAngle

-- equivalent calls inferred from this helper; original call sites unknown
local function getYaw(cframe)
	local _, v = cframe:toEulerAnglesYXZ()
	return sanitizeAngle(v)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getPitch(cframe)
	return sanitizeAngle((cframe:toEulerAnglesYXZ()))
end

local function stepSpringAxis(p, p2, p3, p4, p5)
	local v = sanitizeAngle(p4 - p3)
	local v2 = math.exp(-p2 * p)
	return sanitizeAngle((v * (1 + p2 * p) + p5 * p) * v2 + p3), (p5 * (1 - p2 * p) - v * (p2 * p2 * p)) * v2
end

local class = {}
class.__index = class

function class.new(fRising, fFalling, p3)
	return (setmetatable({
		fRising = fRising,
		fFalling = fFalling,
		g = p3,
		p = p3,
		v = p3 * 0
	}, class))
end

function class:step(p)
	local fRising = self.fRising
	local fFalling = self.fFalling
	local g = self.g
	local p2 = self.p
	local v = self.v

	if v > 0 then
		fFalling = fRising or fFalling
	end

	local v3 = 6.283185307179586 * fFalling
	local v4 = p2 - g
	local v5 = math.exp(-v3 * p)
	local v6 = (v4 * (1 + v3 * p) + v * p) * v5 + g
	local v7 = (v * (1 - v3 * p) - v4 * (v3 * v3 * p)) * v5
	self.p = v6
	self.v = v7
	return v6
end

local class2 = {}
class2.__index = class2

function class2.new(cframe)
	assert(typeof(cframe) == "CFrame")
	local v = {
		yawG = getYaw(cframe),
		yawP = getYaw(cframe),
		yawV = 0,
		pitchG = getPitch(cframe),
		pitchP = getPitch(cframe),
		pitchV = 0,
		fSpringYaw = class.new(
			VehicleCameraConfig.yawReponseDampingRising,
			VehicleCameraConfig.yawResponseDampingFalling,
			0
		),
		fSpringPitch = class.new(
			VehicleCameraConfig.pitchReponseDampingRising,
			VehicleCameraConfig.pitchResponseDampingFalling,
			0
		)
	}
	return (setmetatable(v, class2))
end

function class2:setGoal(cframe)
	assert(typeof(cframe) == "CFrame")
	self.yawG = getYaw(cframe)
	self.pitchG = getPitch(cframe)
end

function class2:getCFrame()
	return CFrame.fromEulerAnglesYXZ(self.pitchP, self.yawP, 0)
end

function class2:step(value, value2, value3, value4)
	assert(typeof(value) == "number")
	assert(typeof(value3) == "number")
	assert(typeof(value2) == "number")
	assert(typeof(value4) == "number")
	local fSpringYaw = self.fSpringYaw
	local fSpringPitch = self.fSpringPitch
	fSpringYaw.g = mapClamp(
		map(value4, 0, 1, value3, 0),
		math.rad(VehicleCameraConfig.cutoffMinAngularVelYaw),
		math.rad(VehicleCameraConfig.cutoffMaxAngularVelYaw),
		1,
		0
	)
	fSpringPitch.g = mapClamp(
		map(value4, 0, 1, value2, 0),
		math.rad(VehicleCameraConfig.cutoffMinAngularVelPitch),
		math.rad(VehicleCameraConfig.cutoffMaxAngularVelPitch),
		1,
		0
	)
	local v = 6.283185307179586 * VehicleCameraConfig.yawStiffness * fSpringYaw:step(value)
	local v2 = 6.283185307179586 * VehicleCameraConfig.pitchStiffness * fSpringPitch:step(value) * map(
		value4,
		0,
		1,
		1,
		VehicleCameraConfig.firstPersonResponseMul
	)
	local v3 = v * map(value4, 0, 1, 1, VehicleCameraConfig.firstPersonResponseMul)
	local yawG = self.yawG
	local yawP = self.yawP
	local yawV = self.yawV
	local v4 = sanitizeAngle(yawP - yawG)
	local v5 = math.exp(-v3 * value)
	local yawP2 = sanitizeAngle((v4 * (1 + v3 * value) + yawV * value) * v5 + yawG)
	local yawV2 = (yawV * (1 - v3 * value) - v4 * (v3 * v3 * value)) * v5
	self.yawP = yawP2
	self.yawV = yawV2
	local pitchG = self.pitchG
	local pitchP = self.pitchP
	local pitchV = self.pitchV
	local v8 = sanitizeAngle(pitchP - pitchG)
	local v9 = math.exp(-v2 * value)
	local pitchP2 = sanitizeAngle((v8 * (1 + v2 * value) + pitchV * value) * v9 + pitchG)
	local pitchV2 = (pitchV * (1 - v2 * value) - v8 * (v2 * v2 * value)) * v9
	self.pitchP = pitchP2
	self.pitchV = pitchV2
	return self:getCFrame()
end

local VehicleCameraCore = {}
VehicleCameraCore.__index = VehicleCameraCore

function VehicleCameraCore.new(p)
	return (setmetatable({
		vrs = class2.new(p)
	}, VehicleCameraCore))
end

function VehicleCameraCore:step(p2, p3, p4, p5)
	return self.vrs:step(p2, p3, p4, p5)
end

function VehicleCameraCore.setTransform(p, p2)
	if CameraUtils.hasGravityRotation() then
		p2 = CameraUtils.getGravityUpCFrame():ToObjectSpace(p2 - p2.Position) + p2.Position
	end

	p.vrs:setGoal(p2)
end

return VehicleCameraCore