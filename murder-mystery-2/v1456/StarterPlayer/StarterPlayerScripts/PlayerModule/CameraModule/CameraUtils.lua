local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local UserGameSettings = UserSettings():GetService("UserGameSettings")
local CameraUtils = {}

local function round(p: number)
	return (math.floor(p + 0.5))
end

local class = {}
class.__index = class

function class.new(freq, p2)
	return (setmetatable({
		freq = freq,
		goal = p2,
		pos = p2,
		vel = 0
	}, class))
end

function class:step(p: number)
	local v = self.freq * 2 * 3.141592653589793
	local goal = self.goal
	local pos = self.pos
	local vel = self.vel
	local v2 = pos - goal
	local v3 = math.exp(-v * p)
	local pos2 = (v2 * (v * p + 1) + vel * p) * v3 + goal
	local vel2 = (vel * (1 - v * p) - v2 * (v * v * p)) * v3
	self.pos = pos2
	self.vel = vel2
	return pos2
end

CameraUtils.Spring = class

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function map(p: number, p2: number, p3: number, p4: number, p5: number)
	return (p - p2) * (p5 - p4) / (p3 - p2) + p4
end

CameraUtils.map = map

function CameraUtils.mapClamp(p: number, p2: number, p3: number, p4: number, p5: number)
	return (math.clamp(map(p, p2, p3, p4, p5), math.min(p4, p5), (math.max(p4, p5))))
end

function CameraUtils.getLooseBoundingSphere(list)
	local positions = table.create(#list)

	for k, v in pairs(list) do
		positions[k] = v.Position
	end

	local v = positions[1]
	local v2 = v
	local v3 = 0

	for _, v4 in ipairs(positions) do
		local magnitude = (v4 - v).Magnitude

		if not (v3 < magnitude) then
			continue
		end

		v2 = v4
		v3 = magnitude
	end

	local v4 = v2
	local v5 = 0

	for _, v6 in ipairs(positions) do
		local magnitude = (v6 - v2).Magnitude

		if not (v5 < magnitude) then
			continue
		end

		v4 = v6
		v5 = magnitude
	end

	local v6 = (v2 + v4) * 0.5
	local v7 = (v2 - v4).Magnitude * 0.5

	for _, v8 in ipairs(positions) do
		local magnitude = (v8 - v6).Magnitude

		if not (v7 < magnitude) then
			continue
		end

		v6 += (magnitude - v7) * 0.5 * (v8 - v6).Unit
		v7 = (magnitude + v7) * 0.5
	end

	return v6, v7
end

function CameraUtils.sanitizeAngle(p: number)
	return (p + 3.141592653589793) % 6.283185307179586 - 3.141592653589793
end

function CameraUtils.Round(p: number, p2: number)
	local v = 10 ^ p2
	return math.floor(p * v + 0.5) / v
end

function CameraUtils.IsFinite(p: number)
	return p == p and p ~= 1e999 and p ~= -1e999
end

function CameraUtils.IsFiniteVector3(vector: Vector3)
	return CameraUtils.IsFinite(vector.X) and CameraUtils.IsFinite(vector.Y) and CameraUtils.IsFinite(vector.Z)
end

function CameraUtils.GetAngleBetweenXZVectors(vector: Vector3, vector2: Vector3)
	return (math.atan2(vector2.X * vector.Z - vector2.Z * vector.X, vector2.X * vector.X + vector2.Z * vector.Z))
end

function CameraUtils.RotateVectorByAngleAndRound(vector: Vector3, p: number, p2: number)
	if vector.Magnitude > 0 then
		local unit = vector.Unit
		local v = math.atan2(unit.Z, unit.X)
		return math.floor((math.atan2(unit.Z, unit.X) + p) / p2 + 0.5) * p2 - v
	else
		return 0
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function SCurveTranform(value: number)
	local v = math.clamp(value, -1, 1)

	if v >= 0 then
		return v * 0.35 / (0.35 - v + 1)
	end

	return -(-v * 0.8 / (v + 0.8 + 1))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function toSCurveSpace(p: number)
	return (math.abs(p) * 2 - 1) * 1.1 - 0.1
end

local function fromSCurveSpace(p: number)
	return p / 2 + 0.5
end

function CameraUtils.GamepadLinearToCurve(point: Vector2)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function onAxis(p)
		local v = p < 0 and -1 or 1
		local sCurveTranform = SCurveTranform(toSCurveSpace(math.abs(p))) -- equivalent call inferred; original call site unknown
		return (math.clamp((sCurveTranform / 2 + 0.5) * v, -1, 1))
	end

	local v = onAxis(point.X) -- equivalent call inferred; original call site unknown
	return Vector2.new(v, onAxis(point.Y))
end

function CameraUtils.ConvertCameraModeEnumToStandard(p)
	if p == Enum.TouchCameraMovementMode.Default then
		return Enum.ComputerCameraMovementMode.Follow
	end

	if p == Enum.ComputerCameraMovementMode.Default then
		return Enum.ComputerCameraMovementMode.Classic
	end

	if p == Enum.TouchCameraMovementMode.Classic or p == Enum.DevTouchCameraMovementMode.Classic or p == Enum.DevComputerCameraMovementMode.Classic or p == Enum.ComputerCameraMovementMode.Classic then
		return Enum.ComputerCameraMovementMode.Classic
	end

	if p == Enum.TouchCameraMovementMode.Follow or p == Enum.DevTouchCameraMovementMode.Follow or p == Enum.DevComputerCameraMovementMode.Follow or p == Enum.ComputerCameraMovementMode.Follow then
		return Enum.ComputerCameraMovementMode.Follow
	end

	if p == Enum.TouchCameraMovementMode.Orbital or p == Enum.DevTouchCameraMovementMode.Orbital or p == Enum.DevComputerCameraMovementMode.Orbital or p == Enum.ComputerCameraMovementMode.Orbital then
		return Enum.ComputerCameraMovementMode.Orbital
	end

	if p == Enum.ComputerCameraMovementMode.CameraToggle or p == Enum.DevComputerCameraMovementMode.CameraToggle then
		return Enum.ComputerCameraMovementMode.CameraToggle
	end

	if p == Enum.DevTouchCameraMovementMode.UserChoice or p == Enum.DevComputerCameraMovementMode.UserChoice then
		return Enum.DevComputerCameraMovementMode.UserChoice
	end

	return Enum.ComputerCameraMovementMode.Classic
end

local function getMouse()
	local localPlayer = Players.LocalPlayer

	if not localPlayer then
		Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
		localPlayer = Players.LocalPlayer
	end

	assert(localPlayer)
	return localPlayer:GetMouse()
end

local icon = ""
local v = nil

function CameraUtils.setMouseIconOverride(icon2: string)
	local localPlayer = Players.LocalPlayer

	if not localPlayer then
		Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
		localPlayer = Players.LocalPlayer
	end

	assert(localPlayer)
	local mouse = localPlayer:GetMouse()

	if mouse.Icon ~= v then
		icon = mouse.Icon
	end

	mouse.Icon = icon2
	v = icon2
end

function CameraUtils.restoreMouseIcon()
	local localPlayer = Players.LocalPlayer

	if not localPlayer then
		Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
		localPlayer = Players.LocalPlayer
	end

	assert(localPlayer)
	local mouse = localPlayer:GetMouse()

	if mouse.Icon == v then
		mouse.Icon = icon
	end

	v = nil
end

local default = Enum.MouseBehavior.Default
local v2 = nil

function CameraUtils.setMouseBehaviorOverride(mouseBehavior)
	if UserInputService.MouseBehavior ~= v2 then
		default = UserInputService.MouseBehavior
	end

	UserInputService.MouseBehavior = mouseBehavior
	v2 = mouseBehavior
end

function CameraUtils.restoreMouseBehavior()
	if UserInputService.MouseBehavior == v2 then
		UserInputService.MouseBehavior = default
	end

	v2 = nil
end

local movementRelative = Enum.RotationType.MovementRelative
local v3 = nil

function CameraUtils.setRotationTypeOverride(rotationType)
	if UserGameSettings.RotationType ~= v3 then
		movementRelative = UserGameSettings.RotationType
	end

	UserGameSettings.RotationType = rotationType
	v3 = rotationType
end

function CameraUtils.restoreRotationType()
	if UserGameSettings.RotationType == v3 then
		UserGameSettings.RotationType = movementRelative
	end

	v3 = nil
end

return CameraUtils