local Spears = {
	["Flimsy Spear"] = {
		Price = 150,
		Description = "...",
		Power = 3,
		Range = 10,
		Handling = 0,
		Piercing = 0,
		Icon = "rbxassetid://137259374427427",
		Color = Color3.fromRGB(154, 170, 190)
	},
	["Steady Spear"] = {
		Price = 15000,
		Description = "...",
		Power = 6,
		Range = 10,
		Handling = 40,
		Piercing = 2.5,
		Icon = "rbxassetid://137259374427427",
		Color = Color3.fromRGB(190, 165, 131)
	},
	["Mini Spear"] = {
		Price = 9000,
		Description = "...",
		Power = 4,
		Range = 6,
		Handling = 0,
		Piercing = 20,
		Icon = "rbxassetid://137259374427427",
		Color = Color3.fromRGB(83, 83, 83)
	},
	["Barbed Spear"] = {
		Price = -1,
		Description = "...",
		Power = 6,
		Range = 10,
		Handling = 10,
		Piercing = 30,
		Icon = "rbxassetid://79743399121943",
		Color = Color3.fromRGB(137, 135, 190),
		Hint = "Made with hands of steel.",
		Recipe = {
			LevelRequired = 0,
			Materials = {
				{
					"Driftwood",
					1,
					"Shrouded",
					"rbxassetid://114790076610770"
				},
				{
					"Barbed Spearhead",
					1,
					nil,
					"rbxassetid://107296900617789"
				}
			}
		},
		Unpurchasable = true
	},
	["Poison-Tipped Spear"] = {
		Price = -1,
		Description = "...",
		Power = 10,
		Range = 10,
		Handling = 30,
		Piercing = 5,
		Icon = "rbxassetid://138599452063390",
		Color = Color3.fromRGB(117, 80, 190),
		Hint = "Be careful, it's poisonous.",
		Recipe = {
			LevelRequired = 0,
			Materials = {
				{
					"Driftwood",
					1,
					"Poisoned",
					"rbxassetid://103350424489790"
				},
				{
					"Poisonous Spearhead",
					1,
					nil,
					"rbxassetid://140054951560787"
				}
			}
		},
		Unpurchasable = true
	},
	["Withered Spear"] = {
		Price = 1750000,
		Description = "...",
		BestiaryRequirement = {
			{
				Island = "Tidefall",
				Requirement = 100
			}
		},
		Power = 15,
		Range = 10,
		Handling = -10,
		Piercing = 3,
		Disturbance = 5,
		PreferredDisturbance = {
			Event = "Plesiosaur",
			Risk = 9
		},
		MutationPool = {
			Withered = 25
		},
		Icon = "rbxassetid://102952105197704",
		Color = Color3.fromRGB(45, 27, 27)
	},
	["Coral Spear"] = {
		Price = 75000,
		Description = "...",
		BestiaryRequirement = {
			{
				Island = "Coral Bastion",
				Requirement = 75
			}
		},
		Power = 4,
		Handling = 20,
		Piercing = 25,
		Range = 10,
		Disturbance = 2,
		PreferredDisturbance = {
			Event = "ReefTitan",
			Risk = 7
		},
		MutationPool = {
			Coral = 100
		},
		Icon = "rbxassetid://101932461671814",
		Color = Color3.fromRGB(214, 172, 255)
	},
	["Royal Spear"] = {
		Price = 3750000,
		Description = "...",
		BestiaryRequirement = {
			{
				Island = "Crowned Ruins",
				Requirement = 100
			}
		},
		Power = 11,
		Range = 10,
		Handling = 23,
		Piercing = 30,
		Disturbance = 4,
		PreferredDisturbance = {
			Event = "Goldwraith",
			Risk = 12
		},
		MutationPool = {
			Royal = 35,
			Midas = 35
		},
		Icon = "rbxassetid://131839759123451",
		Color = Color3.fromRGB(255, 210, 119)
	},
	["Poseidon's Spear"] = {
		Price = 1e999,
		Description = "...",
		LinkedRod = "Poseidon's Lance",
		Power = 7,
		Handling = 23,
		Piercing = 12,
		Range = 10,
		PreferredDisturbance = {
			Event = "TidecrasherArchonHunt",
			Risk = 9
		},
		MutationPool = {
			["Tidal Surge"] = 20
		},
		Icon = "rbxassetid://130549527827482",
		Color = Color3.fromRGB(97, 181, 255),
		Unregistered = true
	},
	["Chitin Piercer"] = {
		Price = 1e999,
		Description = "Crafted from hardened deep-sea chitin, its reinforced tip penetrates tough ocean hides, surging in power when facing larger targets.",
		Power = 9,
		Handling = 19,
		Piercing = 16,
		Range = 10,
		FishingPassives = {
			ChitinPiercer = {
				SizePowerRatio = 10,
				MaxPowerBoost = 10
			}
		},
		Icon = "rbxassetid://91373281178078",
		Color = Color3.fromRGB(228, 255, 185),
		Hint = "Built to take down the largest of fish.",
		Recipe = {
			LevelRequired = 50,
			Materials = {
				{
					"Chitin Plate",
					15,
					nil,
					"rbxassetid://92088013209563"
				},
				{
					"Bone Shard",
					7,
					nil,
					"rbxassetid://111080455697525"
				},
				{
					"Salvage Scrap",
					5,
					nil,
					"rbxassetid://129606824093132"
				}
			}
		},
		Unpurchasable = true
	},
	["Bone Lance"] = {
		Price = 1e999,
		Description = "An unusually long spear fashioned from abyssal bone fragments, piercing through resilient fish with ease while imbuing catches with primal marrow.",
		Power = 16,
		Handling = 24,
		Piercing = 4,
		Range = 20,
		MutationPool = {
			Skeletal = 20
		},
		FishingPassives = {
			BoneLanceSkelefish = {
				CatchRequirement = 3,
				SearchRange = 128,
				MutationPool = {
					Skeletal = 100
				},
				MoveSpeed = 32,
				FishModelName = "BoneLanceSkelefish",
				PassiveBlockLevel = 0
			}
		},
		Icon = "rbxassetid://123832551696109",
		Color = Color3.fromRGB(255, 197, 98),
		Hint = "Bring forth the undead.",
		Recipe = {
			LevelRequired = 50,
			Materials = {
				{
					"Chitin Plate",
					7,
					nil,
					"rbxassetid://92088013209563"
				},
				{
					"Bone Shard",
					15,
					nil,
					"rbxassetid://111080455697525"
				},
				{
					"Salvage Scrap",
					5,
					nil,
					"rbxassetid://129606824093132"
				}
			}
		},
		Unpurchasable = true
	},
	["Prism Spear"] = {
		Price = 1e999,
		Description = "Forged with radiant prism scales, this vibrant spear channels rapid striking speed into devastating kinetic force while bestowing brilliant yields.",
		Power = 12,
		Handling = 32,
		Piercing = 32,
		Range = 10,
		WeightBoost = 30,
		MutationPool = {
			Prism = 35
		},
		ClientFishingPassives = {
			PrismSpear = {
				ForcedProgressSpeedBoost = 0.01,
				Timeout = 1
			}
		},
		Icon = "rbxassetid://108880569135479",
		Color = Color3.fromRGB(255, 172, 209),
		Hint = "Unleash the power of the rainbow.",
		Recipe = {
			LevelRequired = 120,
			Materials = {
				{
					"Bigfin Squid",
					1,
					"Luminous",
					"rbxassetid://131047033608780"
				},
				{
					"Ancient Bone",
					3,
					nil,
					"rbxassetid://130739677810434"
				},
				{
					"Radiant Prism Scale",
					8,
					nil,
					"rbxassetid://77798282361673"
				}
			}
		},
		Unpurchasable = true
	},
	["Artisan Spear"] = {
		Price = 30000,
		MinDistanceToPurchase = 30,
		Description = "Balanced by hand until the craftsman was satisfied, and blessed for the trouble.",
		Power = 14,
		Handling = 26,
		Piercing = 24,
		Range = 12,
		MutationPool = {
			["Kaito's Blessing"] = 25
		},
		Icon = "rbxassetid://118039903503538",
		Color = Color3.fromRGB(214, 89, 66),
		Hint = "Purchasable from Kaito at Skycrest."
	},
	Craftable = {}
}

for k, v in Spears do
	if v.Recipe then
		table.insert(Spears.Craftable, k)
	end
end

return Spears