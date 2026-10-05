local DayNight = require(script.Parent:WaitForChild("DayNight"))
local EggCycle = {
	Period = DayNight.RealTime and DayNight.CycleSeconds or DayNight.SteppedCycleSeconds
}
local v = DayNight.RealTime and DayNight.NightEnd / 24 * DayNight.CycleSeconds or DayNight.NightBeginsAt + DayNight.NightPhaseSeconds

function EggCycle.Now()
	return workspace:GetServerTimeNow()
end

function EggCycle.Index()
	return (math.floor((EggCycle.Now() - v) / EggCycle.Period))
end

function EggCycle.SecondsRemaining()
	return EggCycle.Period - (EggCycle.Now() - v) % EggCycle.Period
end

return EggCycle