local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
require3(ReplicatedStorage2.ServerInfo)
return {
	EndTime = DateTime.fromUniversalTime(2024, 12, 2, 5),
	GlobalEndTime = true,
	TimeToShow = 600,
	TimeShown = 900,
	Markers = {
		TimePlayed = "BlackFridayPackTimePlayed",
		Timer = "BlackFridayPackTimer",
		StartTime = "BlackFridayPackStartTime",
		Popup = "BlackFridayPackPopup"
	},
	Rewards = {
		v.createSwordReward("Infernal Edge"),
		v.createExplosionReward("Robuxplosion"),
		v.createEmoteReward("Kill Collector")
	}
}