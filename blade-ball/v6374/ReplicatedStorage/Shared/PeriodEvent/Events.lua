local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local v = require3(script.Parent.Relics)
require3(script.Parent.Types)
local profiles = {
	TheRising = {
		Id = "TheRising",
		DisplayName = "The Rising",
		Relics = v.TheRising,
		EndTime = DateTime.fromUniversalTime(2025, 11, 1, 18).UnixTimestamp
	},
	BlizzardBreakout = {
		Id = "BlizzardBreakout",
		DisplayName = "Blizzard Breakout",
		Relics = v.BlizzardBreakout,
		EndTime = DateTime.fromUniversalTime(2025, 12, 13, 17).UnixTimestamp
	},
	HolidayHeist = {
		Id = "HolidayHeist",
		DisplayName = "Holiday Heist",
		Relics = v.HolidayHeist,
		EndTime = DateTime.fromUniversalTime(2026, 1, 3, 17).UnixTimestamp
	},
	GalacticCollapse = {
		Id = "GalacticCollapse",
		DisplayName = "Galactic Collapse",
		Relics = v.GalacticCollapse,
		EndTime = DateTime.fromUniversalTime(2026, 3, 14, 17).UnixTimestamp
	},
	SerpentBreakout = {
		Id = "SerpentBreakout",
		DisplayName = "Serpent Breakout",
		Relics = v.SerpentBreakout,
		EndTime = DateTime.fromUniversalTime(2026, 9, 30, 17).UnixTimestamp
	}
}
local Events = {}
Events.Profiles = profiles

function Events.GetActiveEvent()
	local serverTimeNow = workspace:GetServerTimeNow()

	for _, v4 in profiles do
		if serverTimeNow < v4.EndTime then
			return v4
		end
	end

	return nil
end

function Events.GetPriorityEvent()
	local serverTimeNow = workspace:GetServerTimeNow()
	local v3 = nil
	local endTime = -1e999
	local v4 = nil

	for _, v5 in profiles do
		if not v3 and serverTimeNow < v5.EndTime then
			v3 = v5
		end

		if not (endTime < v5.EndTime) then
			continue
		end

		endTime = v5.EndTime
		v4 = v5
	end

	return v3 or v4
end

return Events