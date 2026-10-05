local ReplicatedStorage = game:GetService("ReplicatedStorage")
local lib = require(ReplicatedStorage.shared.modules.SimpleFetchQuests.lib)
require(ReplicatedStorage.shared.modules.Quests.Util)
local color = Color3.fromRGB(190, 210, 255)
local rewards = {
	{ "IdolFavor", 250 },
	{ "DisplayOnly", "Wish Streak +1" }
}
local IdolTrials = {}

local function trial(p: string, p2: string, p3: string, p4: string, list)
	IdolTrials[p] = {
		DisplayName = `Wish of the Sky: {p4}`,
		Description = `Ryusei has directed you to the {p3}.`,
		QuestType = "Challenge",
		AutoNavigate = false,
		AcceptIndicatorTag = "Ryusei",
		NavigationTargets = {
			{
				Zone = "Skycrest",
				Tags = { p2 }
			}
		},
		ResetOnRejoin = "incomplete",
		List = list,
		Rewards = rewards
	}
end

trial("WishTrial_Brawn1", "BrawnIdol", "Goriki Idol", "Resilient Brawn", { lib.CatchFish({
		BiteStats = {
			Resilience = { nil, 15 }
		},
		RequiredAmount = 20,
		DirectCatch = true
	}) })
trial("WishTrial_Brawn2", "BrawnIdol", "Goriki Idol", "Enduring Brawn", { lib.CatchFish({
		BiteStats = {
			ProgressSpeed = { nil, -40 }
		},
		RequiredAmount = 20,
		DirectCatch = true
	}) })
trial("WishTrial_Brawn3", "BrawnIdol", "Goriki Idol", "Controlled Brawn", { lib.CatchFish({
		BiteStats = {
			Control = { 0.7, nil }
		},
		RequiredAmount = 5,
		DirectCatch = true
	}) })
trial("WishTrial_Fortune1", "FortuneIdol", "Ebisu Idol", "Legendary Fortune", { lib.CatchFishAny({
		Raritites = { "Legendary", "Mythical" },
		PlayerZones = { "Skycrest" },
		RequiredAmount = 15
	}) })
trial("WishTrial_Fortune2", "FortuneIdol", "Ebisu Idol", "Glistening Fortune", { lib.CatchFishAny({
		RequiredAttributes = {
			ShinyOrSparkling = true
		},
		RequiredAmount = 8
	}) })
trial("WishTrial_Fortune3", "FortuneIdol", "Ebisu Idol", "Fortunate Find", {
	{ "Custom", 5, "Open 5 Treasure Chests" }
})
trial("WishTrial_Endurance1", "EnduranceIdol", "Fudo Idol", "Consistent Endurance", {
	{ "Custom", 10, "Perfect Catch 10 fish in a row" }
})
trial("WishTrial_Endurance2", "EnduranceIdol", "Fudo Idol", "Precise Endurance", {
	{ "Custom", 10, "Perfect Cast and Perfect Catch 10 fish in a row" }
})
trial("WishTrial_Endurance3", "EnduranceIdol", "Fudo Idol", "Weighty Endurance", { lib.CatchFishAny({
		RequiredAttributes = {
			WeightClass = "Giant"
		},
		RequiredAmount = 10
	}) })
trial("WishTrial_Relaxation1", "RelaxationIdol", "Nagomi Idol", "A Relaxing Catch", { lib.CatchFishAny({
		PlayerZones = { "Skycrest" },
		RequiredAmount = 30
	}) })
trial("WishTrial_Relaxation3", "RelaxationIdol", "Nagomi Idol", "More Relaxing Catches", { lib.CatchFishCage({
		RequiredAmount = 120
	}) })
trial("WishTrial_Rush1", "RushIdol", "Shunsoku Idol", "Rushed Catch", {
	{ "Custom", 10, "<b>Directly</b> Catch 10 fish in under 8 seconds each" }
})
trial("WishTrial_Rush2", "RushIdol", "Shunsoku Idol", "Rushing Potential", { lib.CatchFishAny({
		BiteStats = {
			ProgressSpeed = { 50 }
		},
		RequiredAmount = 20
	}) })
trial("WishTrial_Rush3", "RushIdol", "Shunsoku Idol", "Rushed Selection", {
	{ "Custom", 4, "<b>Directly</b> Hook 2 fish in 15 seconds, 4 times" }
})
trial("WishTrial_Swiftness1", "SwiftnessIdol", "Hayate Idol", "Swift Swimmer", { lib.CatchFishAny({
		PlayerZones = { "Skycrest" },
		RequiredAttributes = {
			Mutation = { "Gusty", "Breezed" }
		},
		RequiredAmount = 12
	}) })
trial("WishTrial_Swiftness3", "SwiftnessIdol", "Hayate Idol", "Swift Winds", { lib.CatchFishAny({
		RequiredAttributes = {
			Mutation = "Squalled"
		},
		RequiredAmount = 10
	}) })

for _, v2 in IdolTrials do
	v2.Icon = ""
	v2.IconColor = color
	v2.NoAutoTrack = false
end

return IdolTrials