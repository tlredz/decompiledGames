local _ = {
	NORMAL = "Normal",
	BRONZE = "Bronze",
	SILVER = "Silver",
	GOLD = "Gold",
	IRIDESCENT = "Iridescent",
	ONYX = "Onyx"
}
local Achievements = require(script.Parent:WaitForChild("Achievements"))
local Titles = {
	SpeedWalker = {
		DisplayName = "Speed Walker",
		UIGradient = "Bronze",
		LinkedAchievementID = "ID_1_SpeedWalker"
	},
	LongDistanceRunner = {
		DisplayName = "Long Distance Runner",
		UIGradient = "Silver",
		LinkedAchievementID = "ID_2_LongDistanceRunner"
	},
	MarathonRunner = {
		DisplayName = "Marathon Runner",
		UIGradient = "Gold",
		LinkedAchievementID = "ID_3_MarathonRunner"
	},
	MachineEnthusiast = {
		DisplayName = "Machine Enthusiast",
		UIGradient = "Bronze",
		LinkedAchievementID = "ID_4_MachineEnthusiast"
	},
	MachineMaster = {
		DisplayName = "Machine Master",
		UIGradient = "Silver",
		LinkedAchievementID = "ID_5_MachineMaster"
	},
	THEMachine = {
		DisplayName = "THE Machine",
		UIGradient = "Gold",
		LinkedAchievementID = "ID_6_THEMachine"
	},
	ItemFinder = {
		DisplayName = "Item Finder",
		UIGradient = "Bronze",
		LinkedAchievementID = "ID_7_ItemFinder"
	},
	ItemTracker = {
		DisplayName = "Item Tracker",
		UIGradient = "Silver",
		LinkedAchievementID = "ID_8_ItemTracker"
	},
	ItemHunter = {
		DisplayName = "Item Hunter",
		UIGradient = "Gold",
		LinkedAchievementID = "ID_9_ItemHunter"
	},
	HissyFit = {
		DisplayName = "Hissy Fit",
		UIGradient = "Iridescent",
		LinkedAchievementID = "ID_10_HissyFit"
	},
	Sightseer = {
		DisplayName = "Sightseer",
		UIGradient = "Silver",
		LinkedAchievementID = "ID_11_Sightseer"
	},
	ClockedIn = {
		DisplayName = "Clocked In",
		UIGradient = "Bronze",
		LinkedAchievementID = "ID_12_ClockedIn"
	},
	Overtime = {
		DisplayName = "Overtime",
		UIGradient = "Iridescent",
		LinkedAchievementID = "ID_13_Overtime"
	},
	GossipBud = {
		DisplayName = "Gossip Bud",
		UIGradient = "Bronze",
		LinkedAchievementID = "ID_21_GossipBud"
	},
	GossipTime = {
		DisplayName = "Gossip Time",
		UIGradient = "Bronze",
		LinkedAchievementID = "ID_22_GossipTime"
	},
	Only90MoreToGo = {
		DisplayName = "Double Digits!",
		UIGradient = "Bronze",
		LinkedAchievementID = "ID_23_Only90MoreToGo"
	},
	Only75More = {
		DisplayName = "Skilled Toon!",
		UIGradient = "Silver",
		LinkedAchievementID = "ID_24_Only75More"
	},
	Halfway50More = {
		DisplayName = "Super Skilled Pro!",
		UIGradient = "Gold",
		LinkedAchievementID = "ID_25_Halfway50More"
	},
	TwistedsFearMe = {
		DisplayName = "Twisteds Fear Me",
		UIGradient = "Iridescent",
		LinkedAchievementID = "ID_26_TwistedsFearMe"
	},
	DandysBud = {
		DisplayName = "Dandy's Bud",
		UIGradient = "Normal",
		Icon = "rbxassetid://108618178190054",
		Image = "rbxassetid://108618178190054",
		Description = "Welcome to Dandy's World!"
	},
	BlossomingBud = {
		DisplayName = "Blossoming Bud",
		UIGradient = "Normal",
		Icon = "rbxassetid://89982790407160",
		Image = "rbxassetid://89982790407160",
		Description = "You're growing into something special."
	},
	Nurturer = {
		DisplayName = "Nurturer",
		UIGradient = "Bronze",
		Image = "rbxassetid://15121698564",
		LinkedAchievementID = "ID_54_Nurturer"
	},
	Caretaker = {
		DisplayName = "Caretaker",
		UIGradient = "Silver",
		Image = "rbxassetid://137138596",
		LinkedAchievementID = "ID_55_Caretaker"
	},
	Cultivator = {
		DisplayName = "Cultivator",
		UIGradient = "Gold",
		Image = "rbxassetid://95073521474278",
		LinkedAchievementID = "ID_56_Cultivator"
	},
	GreenThumb = {
		DisplayName = "Green Thumb",
		UIGradient = "Iridescent",
		Image = "rbxassetid://2373819686",
		LinkedAchievementID = "ID_57_GreenThumb"
	},
	FineDining = {
		DisplayName = "Fine Dining",
		UIGradient = "Gold",
		Image = "rbxassetid://0",
		LinkedAchievementID = "ID_31_FineDining"
	},
	StealthMission = {
		DisplayName = "Stealth Mission",
		UIGradient = "Silver",
		Image = "rbxassetid://0",
		LinkedAchievementID = "ID_32_StealthMission"
	},
	SpeedRunner = {
		DisplayName = "Speed Runner",
		UIGradient = "Gold",
		Image = "rbxassetid://0",
		LinkedAchievementID = "ID_33_SpeedRunner"
	},
	CenterOfAttention = {
		DisplayName = "Center of Attention",
		UIGradient = "Gold",
		Image = "rbxassetid://0",
		LinkedAchievementID = "ID_34_CenterOfAttention"
	},
	MasterOfMany = {
		DisplayName = "Master Of Many",
		UIGradient = "Gold",
		Image = "rbxassetid://0",
		LinkedAchievementID = "ID_35_MasterOfMany"
	},
	WhatADeal = {
		DisplayName = "What a Deal!",
		UIGradient = "Bronze",
		Image = "rbxassetid://0",
		LinkedAchievementID = "ID_36_WhatADeal"
	},
	GearedUp = {
		DisplayName = "Geared Up",
		UIGradient = "Silver",
		Image = "rbxassetid://0",
		LinkedAchievementID = "ID_37_GearedUp"
	},
	MainCharacter = {
		DisplayName = "Main Character",
		UIGradient = "Iridescent",
		Image = "rbxassetid://0",
		LinkedAchievementID = "ID_38_MainCharacter"
	},
	EggHunt26 = {
		DisplayName = "Egg Hunter",
		UIGradient = "Silver",
		Image = "rbxassetid://0",
		LinkedAchievementID = "ID_39_EggHunt26"
	},
	SproutFan = {
		DisplayName = "Sprout Fan",
		UIGradient = "Onyx",
		Image = "rbxassetid://77085480646562",
		Description = "Awarded during Sprout's Toon of the Week!"
	},
	GetToWhere = {
		DisplayName = "Get To Where?",
		UIGradient = "Bronze",
		Image = "rbxassetid://0",
		LinkedAchievementID = "ID_40_GetToWhere"
	},
	Attached = {
		DisplayName = "Attached",
		UIGradient = "Bronze",
		Image = "rbxassetid://0",
		LinkedAchievementID = "ID_41_Attached"
	},
	HelpfulHugger = {
		DisplayName = "Helpful Hugger",
		UIGradient = "Silver",
		Image = "rbxassetid://0",
		LinkedAchievementID = "ID_42_HelpfulHugger"
	},
	Investigator = {
		DisplayName = "Investigator",
		UIGradient = "Bronze",
		Image = "rbxassetid://0",
		LinkedAchievementID = "ID_43_Investigator"
	},
	LightsOut = {
		DisplayName = "Lights Out",
		UIGradient = "Bronze",
		Image = "rbxassetid://0",
		LinkedAchievementID = "ID_44_LightsOut"
	},
	CenterStage = {
		DisplayName = "Center Stage",
		UIGradient = "Silver",
		Image = "rbxassetid://0",
		LinkedAchievementID = "ID_45_CenterStage"
	},
	EmptyHanded = {
		DisplayName = "Empty Handed",
		UIGradient = "Silver",
		Image = "rbxassetid://0",
		LinkedAchievementID = "ID_46_EmptyHanded"
	},
	SqueakyClean = {
		DisplayName = "Squeaky Clean",
		UIGradient = "Silver",
		Image = "rbxassetid://0",
		LinkedAchievementID = "ID_47_SqueakyClean"
	},
	Bedtime = {
		DisplayName = "Bedtime",
		UIGradient = "Silver",
		Image = "rbxassetid://0",
		LinkedAchievementID = "ID_48_Bedtime"
	},
	WinningChoice = {
		DisplayName = "Winning Choice",
		UIGradient = "Gold",
		Image = "rbxassetid://0",
		LinkedAchievementID = "ID_49_WinningChoice"
	},
	QuickReactionTime = {
		DisplayName = "Quick Reaction Time",
		UIGradient = "Gold",
		Image = "rbxassetid://0",
		LinkedAchievementID = "ID_50_QuickReactionTime"
	},
	UnstoppablyHealthy = {
		DisplayName = "Unstoppably Healthy",
		UIGradient = "Silver",
		Image = "rbxassetid://0",
		LinkedAchievementID = "ID_51_UnstoppablyHealthy"
	},
	Teamwork = {
		DisplayName = "Teamwork",
		UIGradient = "Bronze",
		Image = "rbxassetid://0",
		LinkedAchievementID = "ID_52_Teamwork"
	},
	AllTogether = {
		DisplayName = "All Together",
		UIGradient = "Gold",
		Image = "rbxassetid://0",
		LinkedAchievementID = "ID_53_AllTogether"
	},
	SwimmyBarnaby = {
		DisplayName = "Just Keep Swimming",
		UIGradient = "Silver",
		Image = "rbxassetid://0",
		LinkedAchievementID = "ID_58_SwimmyBarnaby"
	},
	ExtinguishedConfidence = {
		DisplayName = "Extinguished Confidence",
		UIGradient = "Silver",
		Image = "rbxassetid://120672097072502",
		LinkedAchievementID = "ID_59_ExtinguishedConfidence"
	},
	FinnFan = {
		DisplayName = "Finn Fan",
		UIGradient = "Onyx",
		Image = "rbxassetid://91397490985910",
		Description = "Awarded during Finn's Toon of the Week!"
	},
	TishaFan = {
		DisplayName = "Tisha Fan",
		UIGradient = "Onyx",
		Image = "rbxassetid://97436317519168",
		Description = "Awarded during Tisha's Toon of the Week!"
	},
	BrushaFan = {
		DisplayName = "Brusha Fan",
		UIGradient = "Onyx",
		Image = "rbxassetid://137192884335147",
		Description = "Awarded during Brusha's Toon of the Week!"
	},
	GigiFan = {
		DisplayName = "Gigi Fan",
		UIGradient = "Onyx",
		Image = "rbxassetid://95638335667435",
		Description = "Awarded during Gigi's Toon of the Week!"
	},
	StashSearcher = {
		DisplayName = "Stash Searcher",
		UIGradient = "Silver",
		Image = "rbxassetid://6794188517",
		LinkedAchievementID = "ID_60_StashSearcher"
	},
	StockpiledStash = {
		DisplayName = "Stockpiled Stash",
		UIGradient = "Gold",
		Image = "rbxassetid://6794188517",
		LinkedAchievementID = "ID_61_StockpiledStash"
	},
	TrickOrTreat26 = {
		DisplayName = "Trick or Treat!",
		UIGradient = "Bronze",
		Image = "rbxassetid://0",
		LinkedAchievementID = "ID_62_TrickOrTreat26"
	},
	HauntedGala26 = {
		DisplayName = "Haunted Gala",
		UIGradient = "Silver",
		Image = "rbxassetid://0",
		LinkedAchievementID = "ID_63_HauntedGala26"
	},
	LockedAway26 = {
		DisplayName = "Locked Away",
		UIGradient = "Gold",
		Image = "rbxassetid://0",
		LinkedAchievementID = "ID_64_LockedAway26"
	}
}

for _, v in pairs(Titles) do
	if not v.LinkedAchievementID then
		continue
	end

	local v2 = Achievements.All.Standard[v.LinkedAchievementID]

	if not v2 then
		continue
	end

	v.Icon = v2.Icon
	v.Description = v2.Description
	v.Category = v2.Category
	v.Difficulty = v2.Difficulty
	v.Image = v.Icon
end

return Titles