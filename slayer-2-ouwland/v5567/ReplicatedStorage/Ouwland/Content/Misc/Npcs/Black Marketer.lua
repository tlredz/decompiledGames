local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Types"):WaitForChild("NpcTypes"))
return {
	Type = Menum.npcType.Stationary,
	Name = script.Name,
	Icon = "rbxassetid://100245949710199",
	TrackedBy = "Night Market Locator",
	Appearance = script:FindFirstChild("BlackMarketer"),
	ModelAttributes = {
		NoDialogueTurn = true
	},
	Animations = {
		idle = { "rbxassetid://83241418829766" }
	},
	Spawns = {
		CFrame.new(-132.676, 804, 101.24, 0, 0, 1, 0, 1, 0, -1, 0, 0),
		CFrame.new(2161.963, 823.459, -900.676, 0, 0, -1, 0, 1, 0, 1, 0, 0),
		CFrame.new(1795.511, 659.399, -523.103, -0.959, 0, 0.285, 0, 1, 0, -0.285, 0, -0.959),
		CFrame.new(-464.862, 1356.974, -3497.761, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		CFrame.new(-2089.845, 62.241, -408.465, -1, 0, 0, 0, 1, 0, 0, 0, -1),
		CFrame.new(-864.695, 1389, -1639.538, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		CFrame.new(-118.712, 1379.275, -1861.278, 0, 0, 1, 0, 1, 0, -1, 0, 0),
		CFrame.new(-1045.371, 1282, -1312.49, -1, 0, 0, 0, 1, 0, 0, 0, -1),
		CFrame.new(-1775.234, 141.75, 1297.076, -1, 0, 0, 0, 1, 0, 0, 0, -1),
		CFrame.new(-2736.262, 143.75, 833.486, 0, 0, 1, 0, 1, 0, -1, 0, 0),
		CFrame.new(-1946.007, 311.5, -282.891, -1, 0, 0, 0, 1, 0, 0, 0, -1)
	},
	TimedVendor = {
		Name = script.Name,
		Seed = 7331,
		TimedEvent = "BlackMarketArrival",
		ActiveFor = 1800,
		SlotCount = {
			Min = 4,
			Max = 6
		},
		SafeZoneRadius = 32,
		Announcement = "[The Black Marketer]<Color=(.8,.7,1)> has slipped into town… find him [before he vanishes.]<Style=Fade,Color=(.6,.6,1)>",
		Odds = {
			Mythic = 5,
			Legendary = 10,
			Epic = 20,
			Rare = 30,
			Common = 35
		},
		Always = {
			"Frozen Heart",
			"Frozen Heart Cache",
			"Frozen Heart Cache x5",
			{
				Name = "Refinement Guard",
				Price = {
					Product = 3709568331
				}
			},
			{
				Name = "Refinement Guard x5",
				Price = {
					Product = 3709568384
				}
			}
		},
		Stock = {
			"Heavenly Boa",
			"Heavenly Crown",
			"Akatsuki Straw Hat",
			"Azure Guard Armour",
			"Gauntlet",
			"Golden Folk Mask",
			"Ashura’s Mask",
			"Wind Earrings",
			"Heart of Night Earrings",
			"Azure Earrings",
			"Crimson Earrings",
			"Mimic Earrings",
			"Ying Yang Haori",
			"Black Dragon Tail",
			"Fox Mask",
			"Tidal Necklace",
			"Healing Gem Earrings",
			"Feather Tassel",
			"Dragon Kesa",
			"Eye Patch",
			"Shades"
		}
	}
}