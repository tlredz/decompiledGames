local ReplicatedStorage = game:GetService("ReplicatedStorage")
local areaEggCycle = require(ReplicatedStorage.Shared.Flags.GameplayBalance).AreaEggCycle
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
require(ReplicatedStorage2.Shared.Globals.Constants)
local t = require(ReplicatedStorage2.Packages.t)

-- equivalent calls inferred from this helper; original call sites unknown
local function periodSeconds()
	return Workspace:GetAttribute("AreaEggCyclePeriodSeconds") or areaEggCycle.PERIOD_SECONDS
end

-- equivalent calls inferred from this helper; original call sites unknown
local function defaultNightSeconds()
	return Workspace:GetAttribute("AreaEggCycleDefaultNightSeconds") or areaEggCycle.NIGHT_SECONDS_DEFAULT
end

local strict = t.strict(t.boolean)
local strict2 = t.strict(t.optional(t.number))
local strict3 = t.strict(t.number)
local AreaEggCycle = {
	ResetPeriodSeconds = periodSeconds(),
	EndingSoonSeconds = 20,
	FinalBlinkSeconds = 10,
	NightGrowthSkipSeconds = areaEggCycle.NIGHT_SKIP_SECONDS,
	MinNightDurationSeconds = areaEggCycle.NIGHT_SECONDS_FLOOR,
	SchedulePollSeconds = 0.25
}

local function scheduleNumber(attributeName: string, p: number)
	local attribute = Workspace:GetAttribute(attributeName)

	if type(attribute) == "number" then
		return attribute
	end

	return p
end

local function frozenAt(p: number)
	local areaEggCycleDisabledAt = Workspace:GetAttribute("AreaEggCycleDisabledAt")

	if type(areaEggCycleDisabledAt) ~= "number" then
		areaEggCycleDisabledAt = p
	end

	return (math.min(p, areaEggCycleDisabledAt))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function requireServer()
	assert(RunService:IsServer(), "Only the server may rewrite the area egg schedule")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function requireLegalNightLength(p: number)
	local v

	if areaEggCycle.NIGHT_SECONDS_FLOOR <= p then
		v = p <= periodSeconds()
	else
		v = false
	end

	assert(v, (("A night of %*s falls outside %*..%*"):format(p, areaEggCycle.NIGHT_SECONDS_FLOOR, periodSeconds())))
end

function AreaEggCycle.NightLengthSeconds()
	local v = defaultNightSeconds() -- equivalent call inferred; original call site unknown
	local areaEggCycleNightSeconds = Workspace:GetAttribute("AreaEggCycleNightSeconds")

	if type(areaEggCycleNightSeconds) == "number" then
		v = areaEggCycleNightSeconds
	end

	return (math.clamp(v, areaEggCycle.NIGHT_SECONDS_FLOOR, periodSeconds()))
end

function AreaEggCycle.NightGrowthRate()
	return areaEggCycle.NIGHT_SKIP_SECONDS / AreaEggCycle.NightLengthSeconds()
end

function AreaEggCycle.IsRunning()
	return Workspace:GetAttribute("AreaEggCycleDisabledAt") == nil
end

function AreaEggCycle.HasScheduleOverride()
	if Workspace:GetAttribute("AreaEggCycleAnchorAt") ~= nil then
		return true
	end

	return Workspace:GetAttribute("AreaEggCycleNightSeconds") ~= nil or not AreaEggCycle.IsRunning()
end

function AreaEggCycle.PeriodStartTime(p: number)
	strict3(p)
	local areaEggCycleAnchorIndex = Workspace:GetAttribute("AreaEggCycleAnchorIndex")
	local v = type(areaEggCycleAnchorIndex) ~= "number" and 0 or areaEggCycleAnchorIndex
	local areaEggCycleAnchorAt = Workspace:GetAttribute("AreaEggCycleAnchorAt")
	return (type(areaEggCycleAnchorAt) ~= "number" and 0 or areaEggCycleAnchorAt) + (p - v) * periodSeconds()
end

function AreaEggCycle.PeriodIndexAt(p: number)
	strict3(p)
	local areaEggCycleDisabledAt = Workspace:GetAttribute("AreaEggCycleDisabledAt")

	if type(areaEggCycleDisabledAt) ~= "number" then
		areaEggCycleDisabledAt = p
	end

	local v = math.min(p, areaEggCycleDisabledAt)
	local areaEggCycleAnchorAt = Workspace:GetAttribute("AreaEggCycleAnchorAt")
	local v2 = v - (type(areaEggCycleAnchorAt) ~= "number" and 0 or areaEggCycleAnchorAt)
	local areaEggCycleAnchorIndex = Workspace:GetAttribute("AreaEggCycleAnchorIndex")
	return (math.max(
		(type(areaEggCycleAnchorIndex) ~= "number" and 0 or areaEggCycleAnchorIndex) + math.floor(v2 / periodSeconds()),
		0
	))
end

function AreaEggCycle.NextResetTime(p: number)
	strict3(p)
	return AreaEggCycle.PeriodStartTime(AreaEggCycle.PeriodIndexAt(p) + 1)
end

function AreaEggCycle.SecondsUntilReset(p: number)
	strict3(p)
	local areaEggCycleDisabledAt = Workspace:GetAttribute("AreaEggCycleDisabledAt")

	if type(areaEggCycleDisabledAt) ~= "number" then
		areaEggCycleDisabledAt = p
	end

	local v = math.min(p, areaEggCycleDisabledAt)
	return (math.max(0, AreaEggCycle.NextResetTime(v) - v))
end

function AreaEggCycle.NightStartTime(p: number)
	strict3(p)
	local areaEggCycleDisabledAt = Workspace:GetAttribute("AreaEggCycleDisabledAt")

	if type(areaEggCycleDisabledAt) ~= "number" then
		areaEggCycleDisabledAt = p
	end

	local v = math.min(p, areaEggCycleDisabledAt)
	return AreaEggCycle.NextResetTime(v) - AreaEggCycle.NightLengthSeconds()
end

function AreaEggCycle.IsNightPhase(p: number)
	strict3(p)
	local areaEggCycleDisabledAt = Workspace:GetAttribute("AreaEggCycleDisabledAt")

	if type(areaEggCycleDisabledAt) ~= "number" then
		areaEggCycleDisabledAt = p
	end

	local v = math.min(p, areaEggCycleDisabledAt)
	return AreaEggCycle.SecondsUntilReset(v) <= AreaEggCycle.NightLengthSeconds()
end

function AreaEggCycle.NightTransitionStartTime(p: number, p2: number, p3: number)
	strict3(p)
	strict3(p2)
	strict3(p3)
	return AreaEggCycle.NightStartTime(p) - p2 + p3
end

function AreaEggCycle.IsWithinNightTransition(p: number, p2: number, p3: number)
	strict3(p)
	strict3(p2)
	strict3(p3)
	local areaEggCycleDisabledAt = Workspace:GetAttribute("AreaEggCycleDisabledAt")

	if type(areaEggCycleDisabledAt) ~= "number" then
		areaEggCycleDisabledAt = p
	end

	local v = math.min(p, areaEggCycleDisabledAt)
	return not AreaEggCycle.IsNightPhase(v) and AreaEggCycle.NightTransitionStartTime(v, p2, p3) <= v
end

function AreaEggCycle.ActivePeriodIndexAt(p: number)
	strict3(p)
	local areaEggCycleDisabledAt = Workspace:GetAttribute("AreaEggCycleDisabledAt")

	if type(areaEggCycleDisabledAt) ~= "number" then
		areaEggCycleDisabledAt = p
	end

	local v = math.min(p, areaEggCycleDisabledAt)
	local periodIndexAt = AreaEggCycle.PeriodIndexAt(v)

	if AreaEggCycle.IsNightPhase(v) then
		return periodIndexAt + 1
	end

	return periodIndexAt
end

function AreaEggCycle.SecondsUntilPhaseEnd(p: number)
	strict3(p)
	local areaEggCycleDisabledAt = Workspace:GetAttribute("AreaEggCycleDisabledAt")

	if type(areaEggCycleDisabledAt) ~= "number" then
		areaEggCycleDisabledAt = p
	end

	local v = math.min(p, areaEggCycleDisabledAt)
	local secondsUntilReset = AreaEggCycle.SecondsUntilReset(v)

	if AreaEggCycle.IsNightPhase(v) then
		return secondsUntilReset
	end

	return (math.max(0, secondsUntilReset - AreaEggCycle.NightLengthSeconds()))
end

function AreaEggCycle.NextNightTime(p: number)
	strict3(p)
	local areaEggCycleDisabledAt = Workspace:GetAttribute("AreaEggCycleDisabledAt")

	if type(areaEggCycleDisabledAt) ~= "number" then
		areaEggCycleDisabledAt = p
	end

	local v = math.min(p, areaEggCycleDisabledAt)
	local nightStartTime = AreaEggCycle.NightStartTime(v)

	if v < nightStartTime then
		return nightStartTime
	end

	return nightStartTime + periodSeconds()
end

function AreaEggCycle.NightGrowthCreditAt(p: number, p2: number)
	strict3(p)
	strict3(p2)
	local areaEggCycleDisabledAt = Workspace:GetAttribute("AreaEggCycleDisabledAt")

	if type(areaEggCycleDisabledAt) ~= "number" then
		areaEggCycleDisabledAt = p
	end

	return math.clamp(math.min(p, areaEggCycleDisabledAt) - p2, 0, AreaEggCycle.NightLengthSeconds()) * AreaEggCycle.NightGrowthRate()
end

function AreaEggCycle.IsCloseToReset(p: number)
	strict3(p)
	return p <= 20
end

function AreaEggCycle.IsInFinalBlink(p: number)
	strict3(p)
	return p <= 10
end

function AreaEggCycle.IsBlinkOnRedFrame(p: number)
	strict3(p)
	return math.ceil(p) % 2 == 0
end

function AreaEggCycle.IsNearResetBoundary(p: number, p2: number)
	strict3(p)
	strict3(p2)
	local nightTime = AreaEggCycle.NextNightTime(p)
	return nightTime - p <= p2 or p - (nightTime - periodSeconds()) <= p2
end

function AreaEggCycle.SetRunning(flag: boolean)
	requireServer() -- equivalent call inferred; original call site unknown
	strict(flag)

	if AreaEggCycle.IsRunning() == flag then
		return
	end

	local v3

	if not flag then
		v3 = Workspace:GetServerTimeNow()
	end

	Workspace:SetAttribute("AreaEggCycleDisabledAt", v3)
end

function AreaEggCycle.OverrideNightLength(areaEggCycleNightSeconds: number?)
	requireServer() -- equivalent call inferred; original call site unknown
	strict2(areaEggCycleNightSeconds)

	if areaEggCycleNightSeconds ~= nil then
		requireLegalNightLength(areaEggCycleNightSeconds) -- equivalent call inferred; original call site unknown
	end

	Workspace:SetAttribute("AreaEggCycleNightSeconds", areaEggCycleNightSeconds)
end

function AreaEggCycle.BeginNight(p: number, p2: number?)
	requireServer() -- equivalent call inferred; original call site unknown
	strict3(p)
	strict2(p2)

	if AreaEggCycle.IsNightPhase(p) then
		return false, "Night is already running"
	end

	local v = p2 or AreaEggCycle.NightLengthSeconds()
	requireLegalNightLength(v) -- equivalent call inferred; original call site unknown
	local periodIndexAt = AreaEggCycle.PeriodIndexAt(p)
	Workspace:SetAttribute("AreaEggCycleNightSeconds", v)
	Workspace:SetAttribute("AreaEggCycleAnchorIndex", periodIndexAt + 1)
	Workspace:SetAttribute("AreaEggCycleAnchorAt", p + v)
	return true, nil
end

function AreaEggCycle.FinishNight(areaEggCycleAnchorAt: number)
	requireServer() -- equivalent call inferred; original call site unknown
	strict3(areaEggCycleAnchorAt)

	if not AreaEggCycle.IsNightPhase(areaEggCycleAnchorAt) then
		return false, "Night is not running"
	end

	Workspace:SetAttribute("AreaEggCycleAnchorIndex", AreaEggCycle.ActivePeriodIndexAt(areaEggCycleAnchorAt))
	Workspace:SetAttribute("AreaEggCycleAnchorAt", areaEggCycleAnchorAt)
	return true, nil
end

function AreaEggCycle.PostponeReset(areaEggCycleAnchorAt: number)
	requireServer() -- equivalent call inferred; original call site unknown
	strict3(areaEggCycleAnchorAt)
	Workspace:SetAttribute("AreaEggCycleAnchorIndex", AreaEggCycle.PeriodIndexAt(areaEggCycleAnchorAt))
	Workspace:SetAttribute("AreaEggCycleAnchorAt", areaEggCycleAnchorAt)
end

function AreaEggCycle.ResetSchedule()
	requireServer() -- equivalent call inferred; original call site unknown
	Workspace:SetAttribute("AreaEggCycleAnchorAt", nil)
	Workspace:SetAttribute("AreaEggCycleAnchorIndex", nil)
	Workspace:SetAttribute("AreaEggCycleNightSeconds", nil)
	Workspace:SetAttribute("AreaEggCycleDisabledAt", nil)
end

local NIGHT_SECONDS_FLOOR = areaEggCycle.NIGHT_SECONDS_FLOOR

local function refreshScheduleBalance(p)
	if p ~= "Game.Balance.AreaEggCycle" then
		return
	end

	if RunService:IsServer() then
		local serverTimeNow = Workspace:GetServerTimeNow()
		local areaEggCycleDisabledAt = Workspace:GetAttribute("AreaEggCycleDisabledAt")

		if type(areaEggCycleDisabledAt) ~= "number" then
			areaEggCycleDisabledAt = serverTimeNow
		end

		local v = math.min(serverTimeNow, areaEggCycleDisabledAt)
		local v2 = periodSeconds() -- equivalent call inferred; original call site unknown
		local v3 = defaultNightSeconds() -- equivalent call inferred; original call site unknown
		local areaEggCycleNightSeconds = Workspace:GetAttribute("AreaEggCycleNightSeconds")

		if type(areaEggCycleNightSeconds) == "number" then
			v3 = areaEggCycleNightSeconds
		end

		local v4 = math.clamp(v3, math.min(NIGHT_SECONDS_FLOOR, v2), v2)
		local PERIOD_SECONDS = areaEggCycle.PERIOD_SECONDS
		local NIGHT_SECONDS_DEFAULT = areaEggCycle.NIGHT_SECONDS_DEFAULT
		local areaEggCycleNightSeconds2 = Workspace:GetAttribute("AreaEggCycleNightSeconds")

		if type(areaEggCycleNightSeconds2) ~= "number" then
			areaEggCycleNightSeconds2 = NIGHT_SECONDS_DEFAULT
		end

		local v5 = math.clamp(areaEggCycleNightSeconds2, areaEggCycle.NIGHT_SECONDS_FLOOR, PERIOD_SECONDS)

		if v2 ~= PERIOD_SECONDS or v4 ~= v5 then
			local periodIndexAt = AreaEggCycle.PeriodIndexAt(v)
			local v6 = math.clamp(v - AreaEggCycle.PeriodStartTime(periodIndexAt), 0, v2)
			local v7

			if v2 - v4 <= v6 then
				v7 = PERIOD_SECONDS - v5 + (v6 - (v2 - v4)) / v4 * v5
			else
				v7 = v6 / (v2 - v4) * (PERIOD_SECONDS - v5)
			end

			Workspace:SetAttribute("AreaEggCycleAnchorIndex", periodIndexAt)
			Workspace:SetAttribute("AreaEggCycleAnchorAt", v - v7)
		end

		Workspace:SetAttribute("AreaEggCyclePeriodSeconds", PERIOD_SECONDS)
		Workspace:SetAttribute("AreaEggCycleDefaultNightSeconds", areaEggCycle.NIGHT_SECONDS_DEFAULT)
	end

	NIGHT_SECONDS_FLOOR = areaEggCycle.NIGHT_SECONDS_FLOOR
	AreaEggCycle.ResetPeriodSeconds = periodSeconds()
	AreaEggCycle.NightGrowthSkipSeconds = areaEggCycle.NIGHT_SKIP_SECONDS
	AreaEggCycle.MinNightDurationSeconds = areaEggCycle.NIGHT_SECONDS_FLOOR
end

if RunService:IsServer() then
	Workspace:SetAttribute("AreaEggCyclePeriodSeconds", areaEggCycle.PERIOD_SECONDS)
	Workspace:SetAttribute("AreaEggCycleDefaultNightSeconds", areaEggCycle.NIGHT_SECONDS_DEFAULT)
end

local BalanceConfig = require(ReplicatedStorage2.Shared.Flags.BalanceConfig)
BalanceConfig.Changed:Connect(refreshScheduleBalance)
Workspace:GetAttributeChangedSignal("AreaEggCyclePeriodSeconds"):Connect(function()
	AreaEggCycle.ResetPeriodSeconds = periodSeconds()
end)
return AreaEggCycle