local createVector = vector.create
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local UserGameSettings = UserSettings():GetService("UserGameSettings")
local CameraUtils = {}
local unit = createVector(0, 1, 0)
local identity = CFrame.identity
local identity2 = CFrame.identity
local v = 0.08
local v2 = nil
local v3 = false
local terrain = workspace.Terrain
local terrain2 = workspace.Terrain
local cFrame = workspace.Terrain.CFrame

local function gravityRotationBetween(unit2: Vector3, vector2: Vector3, vector3: Vector3)
	local dot = unit2:Dot(vector2)
	local cross = unit2:Cross(vector2)

	if dot < -0.99999 then
		local v4 = not (vector3.Magnitude > 0.00001) and createVector(1, 0, 0) or vector3.Unit
		return CFrame.fromAxisAngle(v4, 3.141592653589793)
	else
		return CFrame.new(0, 0, 0, cross.X, cross.Y, cross.Z, 1 + dot)
	end
end

local function gravityTwistAngle(cframe: CFrame, vectorToObjectSpace: Vector3)
	local axisAngle, v4 = cframe:ToAxisAngle()
	local v5 = math.cos(v4 / 2)
	local vector2 = math.sin(v4 / 2) * axisAngle
	local v6 = vector2:Dot(vectorToObjectSpace) * vectorToObjectSpace
	local _, v7 = CFrame.new(0, 0, 0, v6.X, v6.Y, v6.Z, v5):ToAxisAngle()
	return math.sign((vector2:Dot(vectorToObjectSpace))) * v7
end

local function gravityRollAxis(unit2: Vector3)
	local currentCamera = workspace.CurrentCamera
	local vector2 = not currentCamera and createVector(-0, -0, -1) or currentCamera.CFrame.LookVector
	local v4 = vector2 - unit2 * vector2:Dot(unit2)

	if v4.Magnitude > 0.05 then
		return v4.Unit
	end

	return unit2:Cross(math.abs(unit2.X) < 0.9 and createVector(1, 0, 0) or createVector(0, 1, 0)).Unit
end

function CameraUtils.stepGravity(p: number)
	local v4 = v2
	local v5 = not v4 and createVector(0, 1, 0) or v4(unit)
	local v6 = gravityRollAxis(unit)
	local v7 = gravityRotationBetween(unit, v5, v6)
	local v8 = not (v > 0) and 1 or 1 - math.exp(-p / v)
	local lerped = CFrame.new():Lerp(v7, v8)
	unit = (lerped * unit).Unit
	identity = lerped * identity
	local v9

	if terrain == terrain2 then
		local cframe = terrain.CFrame - terrain.CFrame.Position
		local cframe2 = cFrame - cFrame.Position
		local vectorToObjectSpace = cframe:VectorToObjectSpace(unit)
		v9 = gravityTwistAngle(cframe2:ToObjectSpace(cframe), vectorToObjectSpace)
	else
		v9 = 0
	end

	identity2 = CFrame.fromEulerAnglesYXZ(0, v9, 0)
	terrain2 = terrain
	cFrame = terrain.CFrame
end

function CameraUtils.setGravityResolver(callback)
	v2 = callback
end

function CameraUtils.setGravityTau(p: number)
	v = p
end

function CameraUtils.setGravityBodyOwned(flag: boolean)
	v3 = flag
end

function CameraUtils.isGravityBodyOwned()
	return v3
end

function CameraUtils.setGravitySpinPart(p)
	terrain = p or workspace.Terrain
end

function CameraUtils.resetGravity()
	v2 = nil
	v3 = false
	unit = createVector(0, 1, 0)
	identity = CFrame.identity
	identity2 = CFrame.identity
end

function CameraUtils.getGravityUp()
	return unit
end

function CameraUtils.getGravityUpCFrame()
	return identity
end

function CameraUtils.getGravityTwistCFrame()
	return identity2
end

function CameraUtils.hasGravityRotation()
	return identity ~= CFrame.identity or identity2 ~= CFrame.identity
end

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
	local v4 = self.freq * 2 * 3.141592653589793
	local goal = self.goal
	local pos = self.pos
	local vel = self.vel
	local v5 = pos - goal
	local v6 = math.exp(-v4 * p)
	local pos2 = (v5 * (v4 * p + 1) + vel * p) * v6 + goal
	local vel2 = (vel * (1 - v4 * p) - v5 * (v4 * v4 * p)) * v6
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

	for k, v4 in pairs(list) do
		positions[k] = v4.Position
	end

	local v4 = positions[1]
	local v5 = v4
	local v6 = 0

	for _, v7 in ipairs(positions) do
		local magnitude = (v7 - v4).Magnitude

		if not (v6 < magnitude) then
			continue
		end

		v5 = v7
		v6 = magnitude
	end

	local v7 = v5
	local v8 = 0

	for _, v9 in ipairs(positions) do
		local magnitude = (v9 - v5).Magnitude

		if not (v8 < magnitude) then
			continue
		end

		v7 = v9
		v8 = magnitude
	end

	local v9 = (v5 + v7) * 0.5
	local v10 = (v5 - v7).Magnitude * 0.5

	for _, v11 in ipairs(positions) do
		local magnitude = (v11 - v9).Magnitude

		if not (v10 < magnitude) then
			continue
		end

		v9 += (magnitude - v10) * 0.5 * (v11 - v9).Unit
		v10 = (magnitude + v10) * 0.5
	end

	return v9, v10
end

function CameraUtils.sanitizeAngle(p: number)
	return (p + 3.141592653589793) % 6.283185307179586 - 3.141592653589793
end

function CameraUtils.Round(p: number, p2: number)
	local v4 = 10 ^ p2
	return math.floor(p * v4 + 0.5) / v4
end

function CameraUtils.IsFinite(p: number)
	return p == p and p ~= 1e999 and p ~= -1e999
end

function CameraUtils.IsFiniteVector3(vector2: Vector3)
	return CameraUtils.IsFinite(vector2.X) and CameraUtils.IsFinite(vector2.Y) and CameraUtils.IsFinite(vector2.Z)
end

function CameraUtils.GetAngleBetweenXZVectors(vector2: Vector3, vector3: Vector3)
	local vectorToObjectSpace = identity:VectorToObjectSpace(vector2)
	local vectorToObjectSpace2 = identity:VectorToObjectSpace(vector3)
	return (math.atan2(
		vectorToObjectSpace2.X * vectorToObjectSpace.Z - vectorToObjectSpace2.Z * vectorToObjectSpace.X,
		vectorToObjectSpace2.X * vectorToObjectSpace.X + vectorToObjectSpace2.Z * vectorToObjectSpace.Z
	))
end

function CameraUtils.RotateVectorByAngleAndRound(vector2: Vector3, p: number, p2: number)
	if vector2.Magnitude > 0 then
		local unit2 = vector2.Unit
		local v4 = math.atan2(unit2.Z, unit2.X)
		return math.floor((math.atan2(unit2.Z, unit2.X) + p) / p2 + 0.5) * p2 - v4
	else
		return 0
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function SCurveTranform(value: number)
	local v4 = math.clamp(value, -1, 1)

	if v4 >= 0 then
		return v4 * 0.35 / (0.35 - v4 + 1)
	end

	return -(-v4 * 0.8 / (v4 + 0.8 + 1))
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
		local v4 = p < 0 and -1 or 1
		local sCurveTranform = SCurveTranform(toSCurveSpace(math.abs(p))) -- equivalent call inferred; original call site unknown
		return (math.clamp((sCurveTranform / 2 + 0.5) * v4, -1, 1))
	end

	local v4 = onAxis(point.X) -- equivalent call inferred; original call site unknown
	return Vector2.new(v4, onAxis(point.Y))
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
local v4 = nil

function CameraUtils.setMouseIconOverride(icon2: string)
	local localPlayer = Players.LocalPlayer

	if not localPlayer then
		Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
		localPlayer = Players.LocalPlayer
	end

	assert(localPlayer)
	local mouse = localPlayer:GetMouse()

	if mouse.Icon ~= v4 then
		icon = mouse.Icon
	end

	mouse.Icon = icon2
	v4 = icon2
end

function CameraUtils.restoreMouseIcon()
	local localPlayer = Players.LocalPlayer

	if not localPlayer then
		Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
		localPlayer = Players.LocalPlayer
	end

	assert(localPlayer)
	local mouse = localPlayer:GetMouse()

	if mouse.Icon == v4 then
		mouse.Icon = icon
	end

	v4 = nil
end

local default = Enum.MouseBehavior.Default
local v5 = nil

function CameraUtils.setMouseBehaviorOverride(mouseBehavior)
	if UserInputService.MouseBehavior ~= v5 then
		default = UserInputService.MouseBehavior
	end

	UserInputService.MouseBehavior = mouseBehavior
	v5 = mouseBehavior
end

function CameraUtils.restoreMouseBehavior()
	if UserInputService.MouseBehavior == v5 then
		UserInputService.MouseBehavior = default
	end

	v5 = nil
end

local movementRelative = Enum.RotationType.MovementRelative
local v6 = nil

function CameraUtils.setRotationTypeOverride(rotationType)
	if UserGameSettings.RotationType ~= v6 then
		movementRelative = UserGameSettings.RotationType
	end

	UserGameSettings.RotationType = rotationType
	v6 = rotationType
end

function CameraUtils.restoreRotationType()
	if UserGameSettings.RotationType == v6 then
		UserGameSettings.RotationType = movementRelative
	end

	v6 = nil
end

return CameraUtils