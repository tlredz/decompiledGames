local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TimeUtil = require(ReplicatedStorage.Modules.Util.TimeUtil)
return {
	Winter2025Event = {
		ENABLED = false,
		CURRENCY = "Candy"
	},
	LightningEventWeek1 = {
		EVENT_STARTS = "7/1/2025 11:59 PM",
		EVENT_ENDS = "9/30/2025 11:00 AM",
		EVENT_START_TIMESTAMP = TimeUtil.ostimefromstamp("7/1/2025 11:59 PM"),
		EVENT_END_TIMESTAMP = TimeUtil.ostimefromstamp("9/30/2025 11:00 AM")
	},
	CelestialSurge = {
		METER_GOAL = 100000,
		COUNTDOWN_LENGTH = RunService:IsStudio() and 5 or 60,
		EVENT_LENGTH = 180
	},
	Halloween2025 = {
		EventIslands = {
			Sea1 = "Middle Town",
			Sea2 = "Café",
			Sea3 = "Mansion"
		},
		EventIslandTeleportCFrames = {
			Sea1 = "Town",
			Sea2 = "Bar",
			Sea3 = "BigMansion"
		}
	}
}