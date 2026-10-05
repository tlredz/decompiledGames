script.Parent.Parent:WaitForChild("BattlePasses")
return {
	Name = "Halloween",
	Year = "2025",
	Title = "Halloween2025",
	Currency = "Candies2025",
	KeyName = "HalloweenKey2025",
	ShopCover = "rbxassetid://90234103626349",
	ShopButton = "rbxassetid://112176937171925",
	FeaturedIcon = "rbxassetid://112176937171925",
	PrimaryColor = Color3.fromRGB(93, 218, 86),
	MysteryBox = require(script:WaitForChild("MysteryBox")),
	BattlePass = require(script:WaitForChild("BattlePass")),
	ShopItems = require(script:WaitForChild("ShopItems")),
	Remotes = script:WaitForChild("Remotes"),
	LiveLaunchEvent = 1760810520,
	CoinBagIcons = {
		EmptyBag = "rbxassetid://18350588425",
		FullBag = "rbxassetid://18350589657"
	},
	Leaderboards = {
		Points = {
			PauseStartTime = 0,
			PauseEndTime = 0,
			LeaderboardEndTime = 1761807600
		}
	},
	Styles = {
		BackgroundColor3 = {
			UI_PrimaryButtonColor = Color3.fromRGB(93, 218, 86),
			UI_PrimaryButtonShadow = Color3.fromRGB(43, 99, 39),
			UI_DarkBackground = Color3.fromRGB(10, 61, 15)
		},
		Image = {
			UI_Currency = "rbxassetid://112176937171925",
			UI_Key = "rbxassetid://96672799519702"
		}
	},
	Lighting = {
		FogEnd = 175,
		FogStart = 0,
		TimeOfDay = 0,
		Skybox = nil
	},
	ItemPackItems = {
		Knife = {
			ItemID = "XenoKnife",
			GamePassID = 1534775989,
			DevProductID = 3432358695
		},
		Gun = {
			ItemID = "XenoGun",
			GamePassID = 1533049236,
			DevProductID = 3432358848
		},
		Bundle = {
			KnifeItemID = "XenoKnife",
			GunItemID = "XenoGun",
			EffectItemID = "XenoEffect",
			GamePassID = 1535587918,
			DevProductID = 3432360905
		}
	},
	DevProducts = {
		Candies2025 = {
			["800"] = 3432430351,
			["3200"] = 3432430583,
			["6400"] = 3432431049,
			["14280"] = 3432431253,
			["46800"] = 3432431441,
			["116000"] = 3432431607,
			["270000"] = 3432431696
		}
	},
	ProfileData = {
		CurrentTier = 1,
		ClaimedRewards = {},
		FinalRewardClaimAmount = 0,
		LeaderboardPoints = 0,
		LiveClaimed = false
	},
	CurrentState = nil
}