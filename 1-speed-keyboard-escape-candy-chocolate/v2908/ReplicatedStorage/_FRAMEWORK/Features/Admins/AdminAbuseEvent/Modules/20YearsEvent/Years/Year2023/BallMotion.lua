local createVector = vector.create
local Config = require(script.Parent.Config)
require(script.Parent.Types)

-- equivalent calls inferred from this helper; original call sites unknown
local function smoothstep(driftStartAlpha: number, p: number, p2: number)
	local v = math.clamp((p2 - driftStartAlpha) / (p - driftStartAlpha), 0, 1)
	return v * v * (3 - v * 2)
end

local function getDrift(p, vector2: Vector3)
	local v = vector2 - p.aim
	local magnitude = v.Magnitude

	if Config.driftMaxStuds < magnitude then
		return v * (Config.driftMaxStuds / magnitude)
	end

	return v
end

-- equivalent calls inferred from this helper; original call sites unknown
local function horizontalSide(vector2: Vector3)
	local cross = vector2:Cross(createVector(0, 1, 0))

	if cross.Magnitude > 0.001 then
		return cross.Unit
	end

	return createVector(1, 0, 0)
end

local BallMotion = {}

function BallMotion.plan(vector2: Vector3, aim: Vector3, object)
	local v = aim - vector2
	local magnitude = v.Magnitude
	local v2 = object:NextNumber() < 0.5 and -1 or 1
	local number = object:NextNumber(Config.arcSideRatioMin, Config.arcSideRatioMax)
	return {
		origin = vector2,
		control = vector2 + v * 0.5 + horizontalSide(v) * v2 * number * magnitude + createVector(0, 1, 0) * Config.arcUpRatio * magnitude,
		aim = aim,
		duration = math.max(Config.minFlightSeconds, magnitude / Config.ballSpeedStuds)
	}
end

function BallMotion.positionAt(data, p: number, vector2: Vector3?)
	local v = math.clamp(p / data.duration, 0, 1)
	local v2 = v ^ Config.ballEaseExponent
	local aim

	if vector2 then
		local aim2 = data.aim
		local v3 = vector2 - data.aim
		local magnitude = v3.Magnitude

		if Config.driftMaxStuds < magnitude then
			v3 *= Config.driftMaxStuds / magnitude
		end

		aim = aim2 + v3 * smoothstep(Config.driftStartAlpha, 1, v)
	else
		aim = data.aim
	end

	local v3 = 1 - v2
	return data.origin * (v3 * v3) + data.control * (2 * v3 * v2) + aim * (v2 * v2)
end

return BallMotion