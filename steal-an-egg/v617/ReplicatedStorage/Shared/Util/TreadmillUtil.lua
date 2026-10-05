local ReplicatedStorage = game:GetService("ReplicatedStorage")
local treadmillProgression = require(ReplicatedStorage.Shared.Flags.GameplayBalance).TreadmillProgression
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local BossMasteryFlags = require(ReplicatedStorage2.Shared.Flags.BossMasteryFlags)
local Constants = require(ReplicatedStorage2.Shared.Globals.Constants)
require(ReplicatedStorage2.Shared.Modules.ProfileDefaults.Types.Interface)
local Simple = require(ReplicatedStorage2.Packages.FormatNumber.Simple)
local Trails = require(ReplicatedStorage2.Data.Trails)
local t = require(ReplicatedStorage2.Packages.t)
local TreadmillUtil = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function refreshBalanceExports()
	TreadmillUtil.DEFAULT_BASE_SPEED_POWER = treadmillProgression.CURVE_REFERENCE_BASE_WALK_SPEED
	TreadmillUtil.DEFAULT_BASE_SPEED_POWER_PER_STEP = treadmillProgression.DEFAULT_BASE_SPEED_POWER_PER_STEP
	TreadmillUtil.DEFAULT_SPEED_STEP_MULTIPLIER = treadmillProgression.DEFAULT_SPEED_STEP_MULTIPLIER
	TreadmillUtil.TREADMILL_SPEED_GAIN_INTERVAL = treadmillProgression.TREADMILL_SPEED_GAIN_INTERVAL
	TreadmillUtil.MAX_WALK_SPEED = treadmillProgression.CURVE_REFERENCE_MAX_WALK_SPEED
	TreadmillUtil.MAX_SPEED_BOOST_TIER_INDEX = #treadmillProgression.SPEED_BOOST_MULTIPLIERS_BY_TIER
end

refreshBalanceExports() -- equivalent call inferred; original call site unknown
local BalanceConfig = require(ReplicatedStorage2.Shared.Flags.BalanceConfig)
BalanceConfig.Changed:Connect(refreshBalanceExports)

-- equivalent calls inferred from this helper; original call sites unknown
local function resolveCurveLevelFromCurveProgress(p: number)
	if p <= 0 then
		return 0
	end

	local v = 1 + (treadmillProgression.CURVE_XP_GROWTH - 1) * p / treadmillProgression.CURVE_BASE_XP

	if v <= 1 then
		return 0
	end

	return math.log(v) / math.log(treadmillProgression.CURVE_XP_GROWTH)
end

local function resolveReferenceWalkSpeed(p: number)
	if p <= 0 then
		return treadmillProgression.CURVE_REFERENCE_BASE_WALK_SPEED
	end

	return (math.min(
		treadmillProgression.CURVE_REFERENCE_BASE_WALK_SPEED + p * treadmillProgression.CURVE_SPEED_GAIN_PER_LEVEL,
		treadmillProgression.CURVE_REFERENCE_MAX_WALK_SPEED
	))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resolveCurveProgress(p: number)
	return (math.max(p - treadmillProgression.CURVE_REFERENCE_BASE_WALK_SPEED, 0))
end

local function resolveWalkSpeed(p: number)
	if p <= 0 then
		return treadmillProgression.CURVE_REFERENCE_BASE_WALK_SPEED
	end

	local curveLevelFromCurveProgress = resolveCurveLevelFromCurveProgress(p) -- equivalent call inferred; original call site unknown

	if curveLevelFromCurveProgress <= 0 then
		return treadmillProgression.CURVE_REFERENCE_BASE_WALK_SPEED
	end

	return (math.min(
		treadmillProgression.CURVE_REFERENCE_BASE_WALK_SPEED + curveLevelFromCurveProgress * treadmillProgression.CURVE_SPEED_GAIN_PER_LEVEL,
		treadmillProgression.CURVE_REFERENCE_MAX_WALK_SPEED
	))
end

local function remapProgressionWalkSpeedToAppliedWalkSpeed(p: number)
	local v = math.clamp(
		(p - treadmillProgression.CURVE_REFERENCE_BASE_WALK_SPEED) / (treadmillProgression.CURVE_REFERENCE_MAX_WALK_SPEED - treadmillProgression.CURVE_REFERENCE_BASE_WALK_SPEED),
		0,
		1
	)
	return Constants.BASE_WALK_SPEED + v * (treadmillProgression.CURVE_REFERENCE_MAX_WALK_SPEED - Constants.BASE_WALK_SPEED)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function remapAppliedWalkSpeedToProgressionWalkSpeed(p: number)
	local v = math.clamp(
		(p - Constants.BASE_WALK_SPEED) / (treadmillProgression.CURVE_REFERENCE_MAX_WALK_SPEED - Constants.BASE_WALK_SPEED),
		0,
		1
	)
	return treadmillProgression.CURVE_REFERENCE_BASE_WALK_SPEED + v * (treadmillProgression.CURVE_REFERENCE_MAX_WALK_SPEED - treadmillProgression.CURVE_REFERENCE_BASE_WALK_SPEED)
end

local function formatDurationProductLabel(p: number, flag: boolean)
	t.strict(t.number)(p)
	t.strict(t.boolean)(flag)
	local v = math.max(math.floor(p), 0) // 60
	local v2 = v == 1 and "Minute" or "Minutes"

	if v >= 60 and v % 60 == 0 then
		v //= 60

		if v == 1 then
			v2 = "Hour"
		else
			v2 = "Hours"
		end
	end

	if flag then
		v2 = string.upper(v2)
	end

	return (`{v} {v2}`)
end

function TreadmillUtil.NormalizeSpeedPower(p: number?)
	if p == nil then
		return TreadmillUtil.DEFAULT_BASE_SPEED_POWER
	end

	t.strict(t.number)(p)
	return p
end

function TreadmillUtil.SpeedPowerToWalkSpeed(p: number?)
	local v = math.clamp(
		(TreadmillUtil.SpeedPowerToProgressionWalkSpeed(p) - treadmillProgression.CURVE_REFERENCE_BASE_WALK_SPEED) / (treadmillProgression.CURVE_REFERENCE_MAX_WALK_SPEED - treadmillProgression.CURVE_REFERENCE_BASE_WALK_SPEED),
		0,
		1
	)
	return Constants.BASE_WALK_SPEED + v * (treadmillProgression.CURVE_REFERENCE_MAX_WALK_SPEED - Constants.BASE_WALK_SPEED)
end

function TreadmillUtil.SpeedPowerToProgressionWalkSpeed(p: number?)
	local curveProgress = resolveCurveProgress(TreadmillUtil.NormalizeSpeedPower(p)) -- equivalent call inferred; original call site unknown

	if curveProgress <= 0 then
		return treadmillProgression.CURVE_REFERENCE_BASE_WALK_SPEED
	end

	local curveLevelFromCurveProgress = resolveCurveLevelFromCurveProgress(curveProgress) -- equivalent call inferred; original call site unknown

	if curveLevelFromCurveProgress <= 0 then
		return treadmillProgression.CURVE_REFERENCE_BASE_WALK_SPEED
	end

	return (math.min(
		treadmillProgression.CURVE_REFERENCE_BASE_WALK_SPEED + curveLevelFromCurveProgress * treadmillProgression.CURVE_SPEED_GAIN_PER_LEVEL,
		treadmillProgression.CURVE_REFERENCE_MAX_WALK_SPEED
	))
end

function TreadmillUtil.WalkSpeedToSpeedPower(p: number)
	t.strict(t.number)(p)
	local v = math.max(
		remapAppliedWalkSpeedToProgressionWalkSpeed(p) - treadmillProgression.CURVE_REFERENCE_BASE_WALK_SPEED,
		0
	) / treadmillProgression.CURVE_SPEED_GAIN_PER_LEVEL
	local v2 = treadmillProgression.CURVE_BASE_XP * (treadmillProgression.CURVE_XP_GROWTH ^ v - 1) / (treadmillProgression.CURVE_XP_GROWTH - 1)
	return treadmillProgression.CURVE_REFERENCE_BASE_WALK_SPEED + v2
end

function TreadmillUtil.RoundSpeedPowerRequirement(p: number)
	t.strict(t.number)(p)

	if p <= 0 then
		return 0
	end

	local v = 10 ^ math.floor((math.log10(p)))
	local v2 = p / v
	local v3 = v2 < 2 and 0.1 or v2 < 5 and 0.5 or 1
	return math.ceil(v2 / v3) * v3 * v
end

function TreadmillUtil.FormatSpeedPower(p: number?)
	return Simple.FormatCompact(TreadmillUtil.NormalizeSpeedPower(p), ".#")
end

function TreadmillUtil.FormatSpeedPowerPerStep(p: number)
	t.strict(t.number)(p)
	return (`+{Simple.FormatCompact(p, ".#")}/step`)
end

function TreadmillUtil.ResolveEquippedTrailSpeedStepMultiplier(p)
	if p == nil then
		return treadmillProgression.DEFAULT_SPEED_STEP_MULTIPLIER
	end

	local equippedTrail = p.EquippedTrail

	if equippedTrail == nil or p.TrailInventory[equippedTrail] ~= true then
		return treadmillProgression.DEFAULT_SPEED_STEP_MULTIPLIER
	end

	if Trails.TrailNameExists(equippedTrail) then
		return (math.max(
			Trails.Directory[equippedTrail].SpeedMultiplier,
			treadmillProgression.DEFAULT_SPEED_STEP_MULTIPLIER
		))
	end

	return treadmillProgression.DEFAULT_SPEED_STEP_MULTIPLIER
end

function TreadmillUtil.ResolveFinalWalkSpeed(p: number?, value: number?)
	t.strict(t.optional(t.number))(p)
	t.strict(t.optional(t.number))(value)
	local v = value or 1
	local v2

	if v > 0 then
		v2 = v <= 1
	else
		v2 = false
	end

	assert(v2, "Walk speed multiplier must be within (0, 1]")
	return TreadmillUtil.SpeedPowerToWalkSpeed(p) * v
end

function TreadmillUtil.ResolveEffectiveSpeedPower(p: number?, value: number?)
	t.strict(t.optional(t.number))(value)
	local speedPower = TreadmillUtil.NormalizeSpeedPower(p)
	local v = value or 1
	local v2

	if v > 0 then
		v2 = v <= 1
	else
		v2 = false
	end

	assert(v2, "Walk speed multiplier must be within (0, 1]")

	if v == 1 then
		return speedPower
	end

	return TreadmillUtil.WalkSpeedToSpeedPower(TreadmillUtil.ResolveFinalWalkSpeed(speedPower, v))
end

function TreadmillUtil.FormatSpeedMultiplierValue(p: number)
	t.strict(t.number)(p)
	return (`x{Simple.FormatCompact(p, ".#")}`)
end

function TreadmillUtil.FormatSpeedMultiplier(p: number)
	t.strict(t.number)(p)
	return (`{TreadmillUtil.FormatSpeedMultiplierValue(p)} Speed`)
end

function TreadmillUtil.FormatTemporarySpeedBoostProductDuration(p: number)
	return (formatDurationProductLabel(p, true))
end

function TreadmillUtil.FormatTreadmillSpeedEquivalentDuration(p: number)
	return (formatDurationProductLabel(p, false))
end

function TreadmillUtil.GetSpeedBoostMultiplierForTierIndex(p: number)
	t.strict(t.number)(p)
	return treadmillProgression.SPEED_BOOST_MULTIPLIERS_BY_TIER[p] or treadmillProgression.DEFAULT_SPEED_STEP_MULTIPLIER
end

function TreadmillUtil.ResolveSpeedBoostTierIndex(p)
	if p == nil then
		return 0
	end

	return (math.clamp(math.floor(p.SpeedBoostTierIndex), 0, TreadmillUtil.MAX_SPEED_BOOST_TIER_INDEX))
end

function TreadmillUtil.ResolveSpeedBoostSpeedStepMultiplier(p)
	return TreadmillUtil.GetSpeedBoostMultiplierForTierIndex(TreadmillUtil.ResolveSpeedBoostTierIndex(p))
end

function TreadmillUtil.ResolveTemporarySpeedBoostRemainingSeconds(p, serverTimeNow: number?)
	t.strict(t.optional(t.number))(serverTimeNow)

	if p == nil then
		return 0
	end

	local v = math.max(p.TemporarySpeedBoostRemainingSeconds, 0)
	local temporarySpeedBoostActiveStartedAt = p.TemporarySpeedBoostActiveStartedAt

	if temporarySpeedBoostActiveStartedAt > 0 then
		if serverTimeNow == nil then
			serverTimeNow = workspace:GetServerTimeNow()
		end

		v -= math.max(serverTimeNow - temporarySpeedBoostActiveStartedAt, 0)
	end

	return (math.max(v, 0))
end

function TreadmillUtil.ResolveTemporarySpeedBoostSpeedStepMultiplier(p, p2: number?)
	if TreadmillUtil.ResolveTemporarySpeedBoostRemainingSeconds(p, p2) <= 0 then
		return treadmillProgression.DEFAULT_SPEED_STEP_MULTIPLIER
	end

	return BossMasteryFlags.TreadmillBoostMultiplier:Get()
end

function TreadmillUtil.GetTemporarySpeedBoostMultiplier()
	return BossMasteryFlags.TreadmillBoostMultiplier:Get()
end

function TreadmillUtil.ResolveAdditiveSpeedStepMultiplier(DEFAULT_SPEED_STEP_MULTIPLIER: number?, DEFAULT_SPEED_STEP_MULTIPLIER2: number?)
	t.strict(t.optional(t.number))(DEFAULT_SPEED_STEP_MULTIPLIER)
	t.strict(t.optional(t.number))(DEFAULT_SPEED_STEP_MULTIPLIER2)

	if DEFAULT_SPEED_STEP_MULTIPLIER == nil then
		DEFAULT_SPEED_STEP_MULTIPLIER = treadmillProgression.DEFAULT_SPEED_STEP_MULTIPLIER
	end

	if DEFAULT_SPEED_STEP_MULTIPLIER2 == nil then
		DEFAULT_SPEED_STEP_MULTIPLIER2 = treadmillProgression.DEFAULT_SPEED_STEP_MULTIPLIER
	end

	local v = math.max(DEFAULT_SPEED_STEP_MULTIPLIER - treadmillProgression.DEFAULT_SPEED_STEP_MULTIPLIER, 0)
	local v2 = math.max(DEFAULT_SPEED_STEP_MULTIPLIER2 - treadmillProgression.DEFAULT_SPEED_STEP_MULTIPLIER, 0)
	return treadmillProgression.DEFAULT_SPEED_STEP_MULTIPLIER + v + v2
end

function TreadmillUtil.ResolveTreadmillSpeedPowerDelta(p: number, p2: number, p3: number?, p4: number?)
	t.strict(t.number)(p)
	t.strict(t.number)(p2)
	t.strict(t.optional(t.number))(p3)
	t.strict(t.optional(t.number))(p4)
	local v = p4 == nil and 1 or math.max(p4, 0)
	local additiveSpeedStepMultiplier = TreadmillUtil.ResolveAdditiveSpeedStepMultiplier(p2, p3)
	return math.max(p, 0) * additiveSpeedStepMultiplier * v
end

function TreadmillUtil.ResolveSpeedPowerPerStep(p, p2: number?, p3: number?, p4: number?)
	t.strict(t.optional(t.number))(p2)
	t.strict(t.optional(t.number))(p3)
	t.strict(t.optional(t.number))(p4)
	local speedBoostSpeedStepMultiplier = TreadmillUtil.ResolveSpeedBoostSpeedStepMultiplier(p)
	local temporarySpeedBoostSpeedStepMultiplier = TreadmillUtil.ResolveTemporarySpeedBoostSpeedStepMultiplier(p, p3)
	local equippedTrailSpeedStepMultiplier = TreadmillUtil.ResolveEquippedTrailSpeedStepMultiplier(p)
	local treadmillSpeedPowerDelta = TreadmillUtil.ResolveTreadmillSpeedPowerDelta(
		treadmillProgression.DEFAULT_BASE_SPEED_POWER_PER_STEP,
		p2 or treadmillProgression.DEFAULT_SPEED_STEP_MULTIPLIER,
		nil
	)
	local additiveSpeedStepMultiplier = TreadmillUtil.ResolveAdditiveSpeedStepMultiplier(
		speedBoostSpeedStepMultiplier,
		temporarySpeedBoostSpeedStepMultiplier
	)
	local additiveSpeedStepMultiplier2 = TreadmillUtil.ResolveAdditiveSpeedStepMultiplier(
		additiveSpeedStepMultiplier,
		equippedTrailSpeedStepMultiplier
	)
	return treadmillSpeedPowerDelta * TreadmillUtil.ResolveAdditiveSpeedStepMultiplier(additiveSpeedStepMultiplier2, p4)
end

function TreadmillUtil.ResolveSpeedPowerPerSecond(p, p2: number, p3: number?)
	t.strict(t.table)(p)
	t.strict(t.number)(p2)
	t.strict(t.optional(t.number))(p3)
	local speedPowerPerStep = TreadmillUtil.ResolveSpeedPowerPerStep(p, p2, p3)
	local speedPowerToProgressionWalkSpeed = TreadmillUtil.SpeedPowerToProgressionWalkSpeed(p.SpeedPower)
	return speedPowerPerStep / TreadmillUtil.ResolveWalkSpeedPowerAwardInterval(speedPowerToProgressionWalkSpeed)
end

function TreadmillUtil.ResolveTreadmillEquivalentSpeedPower(p, p2: number, p3: number, p4: number?)
	t.strict(t.table)(p)
	t.strict(t.number)(p2)
	t.strict(t.number)(p3)
	t.strict(t.optional(t.number))(p4)
	assert(p3 > 0, "Treadmill equivalent duration must be positive")
	return TreadmillUtil.ResolveSpeedPowerPerSecond(p, p2, p4) * p3
end

function TreadmillUtil.ResolveNextTreadmillSpeedGainAt(p: number)
	t.strict(t.number)(p)
	return p + treadmillProgression.TREADMILL_SPEED_GAIN_INTERVAL
end

function TreadmillUtil.ResolveElapsedTreadmillSpeedGainTicks(p: number, p2: number)
	t.strict(t.number)(p)
	t.strict(t.number)(p2)

	if p2 < p then
		return 0
	end

	return math.floor((p2 - p) / treadmillProgression.TREADMILL_SPEED_GAIN_INTERVAL) + 1
end

function TreadmillUtil.ResolveWalkSpeedPowerAwardInterval(p: number)
	t.strict(t.number)(p)
	local v = math.clamp(
		(p - treadmillProgression.WALK_GAIN_INTERVAL_MIN_SPEED) / (treadmillProgression.WALK_GAIN_INTERVAL_MAX_SPEED - treadmillProgression.WALK_GAIN_INTERVAL_MIN_SPEED),
		0,
		1
	)
	return treadmillProgression.WALK_GAIN_INTERVAL_SLOWEST - v * (treadmillProgression.WALK_GAIN_INTERVAL_SLOWEST - treadmillProgression.WALK_GAIN_INTERVAL_FASTEST)
end

local function findOptionalPresentationPart(instance, childName: string)
	local part = instance:FindFirstChild(childName, true)

	if part == nil then
		return nil
	end

	assert(part:IsA("BasePart"), (`Treadmill "{instance.Name}" {childName} must be a BasePart`))
	return part
end

function TreadmillUtil.FindVideoFeedScreenPart(instance)
	t.strict(t.instanceIsA("Tool"))(instance)
	local videoFeedScreen = instance:FindFirstChild("VideoFeedScreen", true)

	if videoFeedScreen == nil then
		return nil
	end

	assert(videoFeedScreen:IsA("BasePart"), (`Treadmill "{instance.Name}" VideoFeedScreen must be a BasePart`))
	return videoFeedScreen
end

function TreadmillUtil.FindVideoPlayerFolder(ancestor)
	t.strict(t.instanceIsA("Tool"))(ancestor)
	local videoFeedScreenPart = TreadmillUtil.FindVideoFeedScreenPart(ancestor)

	if videoFeedScreenPart == nil then
		return nil
	end

	local folder = videoFeedScreenPart:FindFirstAncestorOfClass("Folder")

	if folder == nil or not folder:IsDescendantOf(ancestor) then
		return nil
	end

	return folder
end

function TreadmillUtil.FindVideoPresentationParts(instance)
	t.strict(t.instanceIsA("Tool"))(instance)
	local videoFeedScreenPart = TreadmillUtil.FindVideoFeedScreenPart(instance)
	local swapLeft = instance:FindFirstChild("SwapLeft", true)

	if swapLeft == nil then
		swapLeft = nil
	else
		assert(swapLeft:IsA("BasePart"), (`Treadmill "{instance.Name}" SwapLeft must be a BasePart`))
	end

	local swapRight = instance:FindFirstChild("SwapRight", true)

	if swapRight == nil then
		swapRight = nil
	else
		assert(swapRight:IsA("BasePart"), (`Treadmill "{instance.Name}" SwapRight must be a BasePart`))
	end

	if videoFeedScreenPart == nil or swapLeft == nil or swapRight == nil then
		return nil, nil, nil
	end

	return videoFeedScreenPart, swapLeft, swapRight
end

function TreadmillUtil.ResolveGroundedToolRootCFrameAtLocation(instance, instance2)
	t.strict(t.instanceIsA("BasePart"))(instance)
	t.strict(t.instanceIsA("Tool"))(instance2)
	local root = instance2.Root
	assert(root:IsA("BasePart"), (`Treadmill "{instance2.Name}" Root must be a BasePart`))
	local boundingBoxPart = instance2.BoundingBoxPart
	assert(boundingBoxPart:IsA("BasePart"), (`Treadmill "{instance2.Name}" BoundingBoxPart must be a BasePart`))
	local pointToObjectSpace = root.CFrame:PointToObjectSpace(boundingBoxPart.CFrame.Position)
	local offset = instance2:GetAttribute("Offset") or 0
	local v = instance.Position + Vector3.new(0, boundingBoxPart.Size.Y * 0.5 + offset, 0)
	return CFrame.new(v) * instance.CFrame.Rotation * CFrame.new(-pointToObjectSpace)
end

return TreadmillUtil