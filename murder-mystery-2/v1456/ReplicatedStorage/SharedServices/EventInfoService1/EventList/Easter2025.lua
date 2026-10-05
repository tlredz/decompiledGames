local rareEggs = script:WaitForChild("RareEggs")
return {
	Name = "Easter",
	Year = "2025",
	Title = "Easter2025",
	Currency = "Eggs2025",
	RareCurrency = "RareEggs2025",
	ShopCover = "rbxassetid://111778291609370",
	ShopButton = "rbxassetid://93997606516273",
	PrimaryColor = Color3.fromRGB(120, 220, 120),
	CoinBagIcons = {
		EmptyBag = "rbxassetid://124750169912761",
		FullBag = "rbxassetid://118335122838129"
	},
	ItemPackItems = {
		Knife = {
			ItemID = "Bloom",
			GamePassID = 1165838634,
			DevProductID = 3268213875
		},
		Gun = {
			ItemID = "Flora",
			GamePassID = 1167438350,
			DevProductID = 3268214475
		},
		Bundle = {
			KnifeItemID = "Bloom",
			GunItemID = "Flora",
			EffectItemID = "Bloom2025",
			GamePassID = 1166580569,
			DevProductID = 3268216220
		}
	},
	RewardTracks = {
		CommonEggs = {
			RequiredMaterial = "Eggs2025",
			Rewards = {
				{
					ItemName = "Carrots_K_2025",
					Cost = 200,
					Type = "Weapons"
				},
				{
					ItemName = "CommonEgg2025",
					Cost = 400,
					Type = "Toys"
				},
				{
					ItemName = "Decorated_K_2025",
					Cost = 800,
					Type = "Weapons"
				},
				{
					ItemName = "Sunny_G_2025",
					Cost = 2000,
					Type = "Weapons"
				},
				{
					ItemName = "Carrots2025",
					Cost = 3000,
					Type = "Effects"
				},
				{
					ItemName = "Bunnies_K_2025",
					Cost = 4000,
					Type = "Weapons"
				}
			}
		},
		RareEggs = {
			RequiredMaterial = "RareEggs2025",
			Rewards = {
				{
					ItemName = "RareEgg2025",
					Cost = 2,
					Type = "Toys"
				},
				{
					ItemName = "Chick_K_2025",
					Cost = 4,
					Type = "Weapons"
				},
				{
					ItemName = "Meadow_G_2025",
					Cost = 6,
					Type = "Weapons"
				},
				{
					ItemName = "Butterflies_G_2025",
					Cost = 8,
					Type = "Weapons"
				},
				{
					ItemName = "Rainbows2025",
					Cost = 10,
					Type = "Effects"
				}
			}
		}
	},
	Remotes = script:WaitForChild("Remotes"),
	CommonEggParts = script:WaitForChild("CommonEggs"),
	RareEggParts = rareEggs,
	RareEggNames = {
		SpeedyEgg2025 = true,
		PoliceEgg2025 = true,
		DiamondEgg2025 = true,
		ConstructionEgg2025 = true,
		RobotEgg2025 = true,
		DoctorEgg2025 = true,
		ScientistEgg2025 = true,
		MilitaryEgg2025 = true,
		ExperimentEgg2025 = true,
		OfficeEgg2025 = true
	},
	RareEggsList = {
		House2 = { rareEggs:WaitForChild("SpeedyEgg2025"), rareEggs:WaitForChild("PoliceEgg2025") },
		Bank2 = { rareEggs:WaitForChild("DiamondEgg2025"), rareEggs:WaitForChild("PoliceEgg2025") },
		Factory = { rareEggs:WaitForChild("ConstructionEgg2025"), rareEggs:WaitForChild("RobotEgg2025") },
		ResearchFacility = { rareEggs:WaitForChild("DoctorEgg2025"), rareEggs:WaitForChild("ScientistEgg2025") },
		MilBase = { rareEggs:WaitForChild("MilitaryEgg2025"), rareEggs:WaitForChild("ExperimentEgg2025") },
		Office3 = { rareEggs:WaitForChild("OfficeEgg2025"), rareEggs:WaitForChild("SpeedyEgg2025") },
		Workplace = { rareEggs:WaitForChild("OfficeEgg2025"), rareEggs:WaitForChild("ConstructionEgg2025") },
		Hotel = { rareEggs:WaitForChild("OfficeEgg2025"), rareEggs:WaitForChild("DiamondEgg2025") },
		BioLab = { rareEggs:WaitForChild("ExperimentEgg2025"), rareEggs:WaitForChild("ScientistEgg2025") },
		Mansion2 = { rareEggs:WaitForChild("SpeedyEgg2025"), rareEggs:WaitForChild("DiamondEgg2025") },
		Hospital3 = { rareEggs:WaitForChild("DoctorEgg2025"), rareEggs:WaitForChild("RobotEgg2025") },
		PoliceStation = { rareEggs:WaitForChild("MilitaryEgg2025"), rareEggs:WaitForChild("PoliceEgg2025") }
	},
	ProfileData = {
		Claimed = {},
		RareEggs = {}
	}
}