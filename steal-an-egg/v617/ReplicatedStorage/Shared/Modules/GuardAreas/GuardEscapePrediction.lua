local ReplicatedStorage = game:GetService("ReplicatedStorage")
local guardPrediction = require(ReplicatedStorage.Shared.Flags.GameplayBalance).GuardPrediction
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local GuardChasePolicy = require(script.Parent.GuardChasePolicy)
local t = require(ReplicatedStorage2.Packages.t)
require(script.Parent.Types.Interface)
local GuardEscapePrediction = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function resolveHorizontalDirection(vector: Vector3)
	local vector2 = Vector3.new(vector.X, 0, vector.Z)
	assert(vector2.Magnitude > 1e-6)
	return vector2.Unit
end

local function resolveAtSpeed(data, p: number)
	if p == 0 then
		return {
			CatchTime = GuardChasePolicy.GetWakingDuration(),
			ExitTime = 1e999,
			Outcome = "Caught"
		}
	end

	local exitTime = data.ExitDistance / p
	local wakingDuration = GuardChasePolicy.GetWakingDuration()

	if exitTime <= wakingDuration then
		return {
			CatchTime = nil,
			ExitTime = exitTime,
			Outcome = "EscapedSafely"
		}
	end

	local horizontalDirection = resolveHorizontalDirection(data.ExitDirection) -- equivalent call inferred; original call site unknown
	local v2 = (data.PlayerStartPosition - data.GuardStartPosition):Dot(horizontalDirection) + p * wakingDuration

	if v2 <= data.HitDistance then
		return {
			CatchTime = wakingDuration,
			ExitTime = exitTime,
			Outcome = "Caught"
		}
	end

	local catchDuration = GuardChasePolicy.ResolveCatchDuration(
		data.BaseGuardWalkSpeed,
		data.FlatRadius,
		data.HitDistance,
		v2,
		p
	)
	local catchTime

	if catchDuration ~= nil then
		catchTime = wakingDuration + catchDuration
	end

	return {
		CatchTime = catchTime,
		ExitTime = exitTime,
		Outcome = catchTime ~= nil and catchTime < exitTime and "Caught" or "EscapedSafely"
	}
end

function GuardEscapePrediction.ResolveExitDistance(cframe: CFrame, vector: Vector3, vector2: Vector3, vector3: Vector3)
	t.strict(t.CFrame)(cframe)
	t.strict(t.Vector3)(vector)
	t.strict(t.Vector3)(vector2)
	t.strict(t.Vector3)(vector3)
	local horizontalDirection = resolveHorizontalDirection(vector3) -- equivalent call inferred; original call site unknown
	local pointToObjectSpace = cframe:PointToObjectSpace(vector2)
	local vectorToObjectSpace = cframe:VectorToObjectSpace(horizontalDirection)
	local v = vector * 0.5
	assert(math.abs(pointToObjectSpace.X) <= v.X + 1e-6)
	assert(math.abs(pointToObjectSpace.Z) <= v.Z + 1e-6)
	local v2

	if math.abs(vectorToObjectSpace.X) > 1e-6 then
		local v3

		if vectorToObjectSpace.X > 0 then
			v3 = v.X
		else
			v3 = -v.X
		end

		v2 = (v3 - pointToObjectSpace.X) / vectorToObjectSpace.X
	else
		v2 = 1e999
	end

	local v3

	if math.abs(vectorToObjectSpace.Z) > 1e-6 then
		local v4

		if vectorToObjectSpace.Z > 0 then
			v4 = v.Z
		else
			v4 = -v.Z
		end

		v3 = (v4 - pointToObjectSpace.Z) / vectorToObjectSpace.Z
	else
		v3 = 1e999
	end

	local v4 = math.min(v2, v3)
	local v5

	if v4 >= 0 then
		v5 = v4 < 1e999
	else
		v5 = false
	end

	assert(v5)
	return v4
end

function GuardEscapePrediction.ResolvePlayerWalkSpeedRequirement(data, p: number)
	t.strict(t.table)(data)
	t.strict(t.number)(p)
	t.strict(t.number)(data.BaseGuardWalkSpeed)
	t.strict(t.Vector3)(data.ExitDirection)
	t.strict(t.number)(data.ExitDistance)
	t.strict(t.number)(data.FlatRadius)
	t.strict(t.Vector3)(data.GuardStartPosition)
	t.strict(t.number)(data.HitDistance)
	t.strict(t.Vector3)(data.PlayerStartPosition)
	assert(data.BaseGuardWalkSpeed > 0)
	assert(data.ExitDistance >= 0)
	assert(data.FlatRadius > 0)
	assert(data.HitDistance > 0)
	local v

	if p > 0 then
		v = p <= 1
	else
		v = false
	end

	assert(v)

	if data.ExitDistance == 0 then
		return 0
	end

	local wakingDuration = GuardChasePolicy.GetWakingDuration()
	local v2 = data.ExitDistance / wakingDuration / p
	local v3 = 0

	for _ = 1, 48 do
		local v4 = (v3 + v2) * 0.5

		if resolveAtSpeed(data, v4 * p).Outcome == "Caught" then
			v3 = v4
		else
			v2 = v4
		end
	end

	return v2
end

function GuardEscapePrediction.ResolveGreenPlayerWalkSpeedRequirement(p)
	return GuardEscapePrediction.ResolvePlayerWalkSpeedRequirement(p, guardPrediction.FULL_GREEN_EGG_CARRY_SPEED_RATIO)
end

function GuardEscapePrediction.ResolveSlowdownTolerance(p: number, p2: number)
	t.strict(t.number)(p)
	t.strict(t.number)(p2)
	assert(p >= 0)
	assert(p2 >= 0)

	if p == 0 then
		return 1
	end

	if p2 == 0 then
		return -1
	end

	return 1 - p / p2
end

function GuardEscapePrediction.Resolve(data)
	t.strict(t.table)(data)
	t.strict(t.number)(data.BaseGuardWalkSpeed)
	t.strict(t.Vector3)(data.ExitDirection)
	t.strict(t.number)(data.ExitDistance)
	t.strict(t.number)(data.FlatRadius)
	t.strict(t.Vector3)(data.GuardStartPosition)
	t.strict(t.number)(data.HitDistance)
	t.strict(t.number)(data.PlayerWalkSpeed)
	t.strict(t.Vector3)(data.PlayerStartPosition)
	assert(data.BaseGuardWalkSpeed > 0)
	assert(data.ExitDistance >= 0)
	assert(data.FlatRadius > 0)
	assert(data.HitDistance > 0)
	assert(data.PlayerWalkSpeed >= 0)
	local v = resolveAtSpeed(data, data.PlayerWalkSpeed)

	if v.Outcome == "Caught" then
		return v
	end

	local v2 = resolveAtSpeed(data, data.PlayerWalkSpeed * guardPrediction.FULL_GREEN_EGG_CARRY_SPEED_RATIO)
	return {
		CatchTime = v.CatchTime,
		ExitTime = v.ExitTime,
		Outcome = v2.Outcome == "Caught" and "EscapedAtRisk" or "EscapedSafely"
	}
end

return GuardEscapePrediction