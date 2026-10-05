local DayNight = {
	RealTime = false,
	HalfCycleSeconds = 300
}
DayNight.CycleSeconds = DayNight.HalfCycleSeconds * 2
DayNight.DayPhaseSeconds = 300
DayNight.NightPhaseSeconds = 120
DayNight.TransitionSeconds = 3
DayNight.DayHour = 10
DayNight.NightHour = 0
DayNight.DayHoldSeconds = DayNight.DayPhaseSeconds - DayNight.TransitionSeconds
DayNight.NightHoldSeconds = DayNight.NightPhaseSeconds - DayNight.TransitionSeconds
DayNight.SteppedCycleSeconds = DayNight.DayPhaseSeconds + DayNight.NightPhaseSeconds
DayNight.NightBeginsAt = DayNight.DayHoldSeconds + DayNight.TransitionSeconds / 2
DayNight.NightGrowthRate = 10
DayNight.NightStart = 18
DayNight.NightEnd = 6

-- equivalent calls inferred from this helper; original call sites unknown
local function Ease(value: number)
	local v = math.clamp(value, 0, 1)
	return v * v * (3 - v * 2)
end

function DayNight.ClockTimeAt(p: number)
	if DayNight.RealTime then
		return p % DayNight.CycleSeconds / DayNight.CycleSeconds * 24
	end

	local dayHoldSeconds = DayNight.DayHoldSeconds
	local nightHoldSeconds = DayNight.NightHoldSeconds
	local transitionSeconds = DayNight.TransitionSeconds
	local v = p % DayNight.SteppedCycleSeconds

	if v < dayHoldSeconds then
		return DayNight.DayHour
	end

	if v < dayHoldSeconds + transitionSeconds then
		local ease = Ease((v - dayHoldSeconds) / transitionSeconds) -- equivalent call inferred; original call site unknown
		return (DayNight.DayHour + ease * 12) % 24
	else
		if v < dayHoldSeconds + transitionSeconds + nightHoldSeconds then
			return DayNight.NightHour
		end

		local ease = Ease((v - (dayHoldSeconds + transitionSeconds + nightHoldSeconds)) / transitionSeconds) -- equivalent call inferred; original call site unknown
		return (DayNight.NightHour + ease * 12) % 24
	end
end

function DayNight.Now()
	return DayNight.ClockTimeAt(workspace:GetServerTimeNow())
end

function DayNight.IsNightAt(p: number)
	if DayNight.RealTime then
		return DayNight.IsNight(DayNight.ClockTimeAt(p))
	end

	local v = p % DayNight.SteppedCycleSeconds
	return DayNight.NightBeginsAt <= v and v < DayNight.NightBeginsAt + DayNight.NightPhaseSeconds
end

function DayNight.IsNight(p: number?)
	if p == nil then
		return DayNight.IsNightAt(workspace:GetServerTimeNow())
	end

	return DayNight.NightStart <= p or p < DayNight.NightEnd
end

function DayNight.SecondsUntilNextPhase(p: number?)
	if DayNight.RealTime then
		local clockTimeAt = DayNight.ClockTimeAt(p or workspace:GetServerTimeNow())
		return ((DayNight.IsNight(clockTimeAt) and (DayNight.NightStart <= clockTimeAt and 24 + DayNight.NightEnd or DayNight.NightEnd) or DayNight.NightStart) - clockTimeAt) / 24 * DayNight.CycleSeconds
	end

	local v = (p or workspace:GetServerTimeNow()) % DayNight.SteppedCycleSeconds
	local nightBeginsAt = DayNight.NightBeginsAt

	for _, v2 in { nightBeginsAt, nightBeginsAt + DayNight.NightPhaseSeconds } do
		if v < v2 then
			return v2 - v
		end
	end

	return DayNight.SteppedCycleSeconds - v + nightBeginsAt
end

-- equivalent calls inferred from this helper; original call sites unknown
local function NightSecondsUpTo(p: number)
	local steppedCycleSeconds = DayNight.SteppedCycleSeconds
	local nightBeginsAt = DayNight.NightBeginsAt
	local v = nightBeginsAt + DayNight.NightPhaseSeconds
	return math.floor(p / steppedCycleSeconds) * DayNight.NightPhaseSeconds + math.clamp(
		p % steppedCycleSeconds,
		nightBeginsAt,
		v
	) - nightBeginsAt
end

function DayNight.NightSecondsBetween(p: number, p2: number)
	if p2 <= p then
		return 0
	end

	local nightSecondsUpTo = NightSecondsUpTo(p2) -- equivalent call inferred; original call site unknown
	return nightSecondsUpTo - NightSecondsUpTo(p)
end

function DayNight.GrowthElapsed(p: number, p2: number?)
	local v = p2 or workspace:GetServerTimeNow()

	if v <= p then
		return 0
	end

	local nightSecondsBetween = DayNight.NightSecondsBetween(p, v)
	return v - p + nightSecondsBetween * (DayNight.NightGrowthRate - 1)
end

function DayNight.GrowthRealRemaining(p: number, p2: number, p3: number?)
	local v = p3 or workspace:GetServerTimeNow()
	local v2 = (tonumber(p2) or 0) - DayNight.GrowthElapsed(p, v)

	if v2 <= 0 then
		return 0
	end

	local v3 = v

	for _ = 1, 2000 do
		local nightGrowthRate = DayNight.IsNightAt(v) and DayNight.NightGrowthRate or 1
		local secondsUntilNextPhase = DayNight.SecondsUntilNextPhase(v)
		local v4 = secondsUntilNextPhase * nightGrowthRate

		if v2 <= v4 then
			return v - v3 + v2 / nightGrowthRate
		end

		v2 -= v4
		v += secondsUntilNextPhase
	end

	return 1e999
end

return DayNight