local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
return {
	TrackImpression = require3(ReplicatedStorage2.Packages.Net):RemoteEvent("AnalyticsTrackImpression"),
	Impressions = {
		KongMap = {
			Type = "Map",
			Name = "HollowEarth",
			ImpressionCooldown = 30,
			Disabled = true
		},
		KongUI = {
			Type = "UI",
			Name = "SpecialSwordTraining",
			Disabled = true
		},
		KongNPC = {
			Type = "Model",
			Name = "KongNPC",
			MinimumExposureTime = 3,
			MaximumViewDistance = 50,
			ImpressionCooldown = 30,
			Disabled = true
		},
		RobloxClassicEvent = {
			Type = "Map",
			Name = "RobloxClassicEvent",
			ImpressionCooldown = 30,
			Disabled = true
		},
		RobloxEvent = {
			Type = "UI",
			Name = "RobloxEvent",
			ImpressionCooldown = 15,
			Disabled = true
		},
		ICC_Stadium_Map = {
			Type = "Map",
			Name = "StadiumICC",
			ImpressionCooldown = 30,
			Disabled = true
		},
		ICC_Quest_UI = {
			Type = "UI",
			Name = "SpecialSwordTraining",
			ImpressionCooldown = 15,
			Disabled = true
		},
		ICC_NPC = {
			Type = "Model",
			Name = "ICCNPC",
			MinimumExposureTime = 3,
			MaximumViewDistance = 50,
			ImpressionCooldown = 30,
			Disabled = true
		}
	}
}