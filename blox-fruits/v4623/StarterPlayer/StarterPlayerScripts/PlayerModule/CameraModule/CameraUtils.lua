local CameraUtils = {}

local function round(p)
	return (math.floor(p + 0.5))
end

function CameraUtils.Clamp(p, p2, p3)
	return (math.min(math.max(p3, p), p2))
end

function CameraUtils.Round(p, p2)
	local v = 10 ^ p2
	return math.floor(p * v + 0.5) / v
end

function CameraUtils.IsFinite(p)
	return p == p and p ~= 1e999 and p ~= -1e999
end

function CameraUtils.IsFiniteVector3(data)
	return CameraUtils.IsFinite(data.X) and CameraUtils.IsFinite(data.Y) and CameraUtils.IsFinite(data.Z)
end

function CameraUtils.GetAngleBetweenXZVectors(p, p2)
	return (math.atan2(p2.X * p.Z - p2.Z * p.X, p2.X * p.X + p2.Z * p.Z))
end

function CameraUtils.RotateVectorByAngleAndRound(p, p2, p3)
	if p.Magnitude > 0 then
		local unit = p.unit
		local v = math.atan2(unit.z, unit.x)
		return math.floor((math.atan2(unit.z, unit.x) + p2) / p3 + 0.5) * p3 - v
	else
		return 0
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function SCurveTranform(p)
	local clamped = CameraUtils.Clamp(-1, 1, p)

	if clamped >= 0 then
		return 0.35 * clamped / (0.35 - clamped + 1)
	end

	return -(0.8 * -clamped / (0.8 + clamped + 1))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function toSCurveSpace(p)
	return (math.abs(p) * 2 - 1) * 1.1 - 0.1
end

local function fromSCurveSpace(p)
	return p / 2 + 0.5
end

function CameraUtils.GamepadLinearToCurve(p)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function onAxis(y)
		local v = y < 0 and -1 or 1
		local sCurveSpace = toSCurveSpace(math.abs(y)) -- equivalent call inferred; original call site unknown
		local sCurveTranform = SCurveTranform(sCurveSpace) -- equivalent call inferred; original call site unknown
		local v4 = (sCurveTranform / 2 + 0.5) * v
		return CameraUtils.Clamp(-1, 1, v4)
	end

	return Vector2.new(onAxis(p.x), onAxis(p.y))
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

	if p == Enum.DevTouchCameraMovementMode.UserChoice or p == Enum.DevComputerCameraMovementMode.UserChoice then
		return Enum.DevComputerCameraMovementMode.UserChoice
	end

	return Enum.ComputerCameraMovementMode.Classic
end

return CameraUtils