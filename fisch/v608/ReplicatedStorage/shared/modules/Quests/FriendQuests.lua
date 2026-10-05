local module = require("./Util")
return {
	FriendQuest1 = {
		DisplayName = "Friend Quest: Bait Crates",
		Icon = "rbxassetid://99280730888394",
		IconColor = Color3.fromRGB(212, 0, 255),
		QuestType = "Challenge",
		QuestSeries = "Friend Quest",
		NoAutoTrack = true,
		Description = "You've accepted a challenge from Marlon! Make sure to bring a friend!",
		CompletedDescription = "",
		List = { module.SaneCatchFishObjective({
				RequiredAmount = 10,
				Fish = "Bait Crate"
			}) },
		Rewards = {
			{ "DisplayOnly", "<b>1-2 Reward Spin(s)</b>" }
		}
	},
	FriendQuest2 = {
		DisplayName = "Friend Quest: Catching Commons",
		Icon = "rbxassetid://99280730888394",
		IconColor = Color3.fromRGB(212, 0, 255),
		QuestType = "Challenge",
		QuestSeries = "Friend Quest",
		NoAutoTrack = true,
		Description = "You've accepted a challenge from Marlon! Make sure to bring a friend!",
		CompletedDescription = "",
		List = { module.SaneCatchFishObjective({
				RequiredAmount = 50,
				Raritites = "Common"
			}) },
		Rewards = {
			{ "DisplayOnly", "<b>1-2 Reward Spin(s)</b>" }
		}
	},
	FriendQuest3 = {
		DisplayName = "Friend Quest: Use 25 Bait",
		Icon = "rbxassetid://99280730888394",
		IconColor = Color3.fromRGB(212, 0, 255),
		QuestType = "Challenge",
		QuestSeries = "Friend Quest",
		NoAutoTrack = true,
		Description = "You've accepted a challenge from Marlon! Make sure to bring a friend!",
		CompletedDescription = "",
		List = {
			{ "BaitUse", 25 }
		},
		Rewards = {
			{ "DisplayOnly", "<b>1-2 Reward Spin(s)</b>" }
		}
	},
	FriendQuest4 = {
		DisplayName = "Friend Quest: Use 30 Bait",
		Icon = "rbxassetid://99280730888394",
		IconColor = Color3.fromRGB(212, 0, 255),
		QuestType = "Challenge",
		QuestSeries = "Friend Quest",
		NoAutoTrack = true,
		Description = "You've accepted a challenge from Marlon! Make sure to bring a friend!",
		CompletedDescription = "",
		List = {
			{ "BaitUse", 30 }
		},
		Rewards = {
			{ "DisplayOnly", "<b>1-2 Reward Spin(s)</b>" }
		}
	},
	FriendQuest5 = {
		DisplayName = "Friend Quest: Sell Fish",
		Icon = "rbxassetid://99280730888394",
		IconColor = Color3.fromRGB(212, 0, 255),
		QuestType = "Challenge",
		QuestSeries = "Friend Quest",
		NoAutoTrack = true,
		Description = "You've accepted a challenge from Marlon! Make sure to bring a friend!",
		CompletedDescription = "",
		List = {
			{ "SellFish", 25 }
		},
		Rewards = {
			{ "DisplayOnly", "<b>1-2 Reward Spin(s)</b>" }
		}
	},
	FriendQuest6 = {
		DisplayName = "Friend Quest: Appraise 10 Fish",
		Icon = "rbxassetid://99280730888394",
		IconColor = Color3.fromRGB(212, 0, 255),
		QuestType = "Challenge",
		QuestSeries = "Friend Quest",
		NoAutoTrack = true,
		Description = "You've accepted a challenge from Marlon! Make sure to bring a friend!",
		CompletedDescription = "",
		List = {
			{ "AppraiseFish", 10 }
		},
		Rewards = {
			{ "DisplayOnly", "<b>1-2 Reward Spin(s)</b>" }
		}
	},
	FriendQuest7 = {
		DisplayName = "Friend Quest: Appraise 5 Fish",
		Icon = "rbxassetid://99280730888394",
		IconColor = Color3.fromRGB(212, 0, 255),
		QuestType = "Challenge",
		QuestSeries = "Friend Quest",
		NoAutoTrack = true,
		Description = "You've accepted a challenge from Marlon! Make sure to bring a friend!",
		CompletedDescription = "",
		List = {
			{ "AppraiseFish", 5 }
		},
		Rewards = {
			{ "DisplayOnly", "<b>1-2 Reward Spin(s)</b>" }
		}
	},
	FriendQuest8 = {
		DisplayName = "Friend Quest: Moosewood Shiny Hunting",
		Icon = "rbxassetid://99280730888394",
		IconColor = Color3.fromRGB(212, 0, 255),
		QuestType = "Challenge",
		QuestSeries = "Friend Quest",
		NoAutoTrack = true,
		Description = "You've accepted a challenge from Marlon! Make sure to bring a friend!",
		CompletedDescription = "",
		List = { module.SaneCatchFishObjective({
				RequiredAmount = 1,
				RequiredAttributes = {
					Shiny = true
				},
				PlayerZones = { "Moosewood" }
			}) },
		Rewards = {
			{ "DisplayOnly", "<b>1-2 Reward Spin(s)</b>" }
		}
	},
	FriendQuest9 = {
		DisplayName = "Friend Quest: Roslit Fishing",
		Icon = "rbxassetid://99280730888394",
		IconColor = Color3.fromRGB(212, 0, 255),
		QuestType = "Challenge",
		QuestSeries = "Friend Quest",
		NoAutoTrack = true,
		Description = "You've accepted a challenge from Marlon! Make sure to bring a friend!",
		CompletedDescription = "",
		List = { module.SaneCatchFishObjective({
				RequiredAmount = 10,
				PlayerZones = { "Roslit" }
			}) },
		Rewards = {
			{ "DisplayOnly", "<b>1-2 Reward Spin(s)</b>" }
		}
	},
	FriendQuest10 = {
		DisplayName = "Friend Quest: Sunstone Fishing",
		Icon = "rbxassetid://99280730888394",
		IconColor = Color3.fromRGB(212, 0, 255),
		QuestType = "Challenge",
		QuestSeries = "Friend Quest",
		NoAutoTrack = true,
		Description = "You've accepted a challenge from Marlon! Make sure to bring a friend!",
		CompletedDescription = "",
		List = { module.SaneCatchFishObjective({
				RequiredAmount = 20,
				PlayerZones = { "Sunstone" }
			}) },
		Rewards = {
			{ "DisplayOnly", "<b>1-2 Reward Spin(s)</b>" }
		}
	}
}