script.Parent.Parent:WaitForChild("BattlePasses")
return {
	Name = "Summer",
	Year = "2025",
	Title = "Summer2025",
	Currency = "BeachBalls2025",
	KeyName = "SummerKey2025",
	ShopCover = "rbxassetid://76437356338798",
	ShopButton = "rbxassetid://13932988534",
	FeaturedIcon = "rbxassetid://110525374723576",
	PrimaryColor = Color3.fromRGB(120, 220, 120),
	MysteryBox = require(script:WaitForChild("MysteryBox")),
	BattlePass = require(script:WaitForChild("BattlePass")),
	ShopItems = require(script:WaitForChild("ShopItems")),
	Remotes = script:WaitForChild("Remotes"),
	CoinBagIcons = {
		EmptyBag = "rbxassetid://18350588425",
		FullBag = "rbxassetid://18350589657"
	},
	Leaderboards = {
		Points = {
			PauseStartTime = 0,
			PauseEndTime = 0,
			LeaderboardEndTime = 1754031600
		}
	},
	Styles = {
		BackgroundColor3 = {
			UI_PrimaryButtonColor = Color3.fromRGB(163, 136, 180),
			UI_PrimaryButtonShadow = Color3.fromRGB(61, 51, 68),
			UI_DarkBackground = Color3.fromRGB(48, 43, 56)
		},
		Image = {
			UI_Currency = "rbxassetid://13932988534",
			UI_Key = "rbxassetid://134240302664368"
		}
	},
	ItemPackItems = {
		Evo = {
			ItemID = "Synthwave",
			GamePassID = 1326724250
		}
	},
	DevProducts = {
		BeachBalls2025 = {
			["800"] = 3337628474,
			["3200"] = 3337628748,
			["6400"] = 3337629198,
			["14280"] = 3337630029,
			["46800"] = 3337630347,
			["116000"] = 3337630826,
			["270000"] = 3337631043
		}
	},
	ProfileData = {
		CurrentTier = 1,
		ClaimedRewards = {},
		FinalRewardClaimAmount = 0,
		LeaderboardPoints = 0
	}
}