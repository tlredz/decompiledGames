local RarityUtil = require(game.ReplicatedStorage.Modules.Asset.RarityUtil)
local rarity = assert(RarityUtil.tryGetRarity("Common")).Value
local rarity2 = assert(RarityUtil.tryGetRarity("Uncommon")).Value
local rarity3 = assert(RarityUtil.tryGetRarity("Rare")).Value
local _ = assert(RarityUtil.tryGetRarity("Legendary")).Value
local _ = assert(RarityUtil.tryGetRarity("Mythical")).Value
local CraftingRecipes = {
	CommonScroll = {
		Ingredients = {
			["Shark Tooth"] = 2,
			["Fool's Gold"] = 3
		},
		Reward = { "Common Scroll", 1 },
		MultiCraft = true
	},
	RareScroll = {
		Ingredients = {
			["Electric Wing"] = 2,
			["Shark Tooth"] = 4,
			["Fool's Gold"] = 5
		},
		Reward = { "Rare Scroll", 1 },
		ProgressionRequirement = {
			["Common Scroll"] = 10
		},
		MultiCraft = true
	},
	LegendaryScroll = {
		Ingredients = {
			["Leviathan Scale"] = 5,
			["Mutant Tooth"] = 1,
			["Electric Wing"] = 3,
			["Fool's Gold"] = 7
		},
		Reward = { "Legendary Scroll", 1 },
		ProgressionRequirement = {
			["Rare Scroll"] = 10
		},
		MultiCraft = true
	},
	MythicalScroll = {
		Ingredients = {
			["Leviathan Scale"] = 15,
			["Leviathan Heart"] = 1,
			["Fool's Gold"] = 20,
			["Terror Eyes"] = 1
		},
		Reward = { "Mythical Scroll", 1 },
		ProgressionRequirement = {
			["Legendary Scroll"] = 10
		},
		MultiCraft = true
	},
	ToothNecklace = {
		Ingredients = {
			["Mutant Tooth"] = 1,
			["Shark Tooth"] = 5
		},
		Reward = { "Shark Tooth Necklace", true }
	},
	TerrorJaw = {
		Ingredients = {
			["Shark Tooth"] = 5,
			["Mutant Tooth"] = 2,
			["Terror Eyes"] = 1,
			["Fool's Gold"] = 10
		},
		Reward = { "Terror Jaw", true }
	},
	SharkAnchor = {
		Ingredients = {
			["Shark Tooth"] = 10,
			["Electric Wing"] = 8,
			["Terror Eyes"] = 2,
			["Fool's Gold"] = 20
		},
		Reward = { "Monster Magnet", 1 }
	},
	LeviathanCrown = {
		Ingredients = {
			["Leviathan Scale"] = 10,
			["Electric Wing"] = 5,
			["Dark Fragment"] = 1
		},
		Reward = { "Leviathan Crown", true }
	},
	LeviathanShield = {
		Ingredients = {
			["Leviathan Scale"] = 30,
			["Electric Wing"] = 10,
			["Mirror Fractal"] = 1,
			["Fool's Gold"] = 20
		},
		Reward = { "Leviathan Shield", true }
	},
	LeviathanBoat = {
		Ingredients = {
			["Leviathan Scale"] = 20,
			["Electric Wing"] = 6,
			["Shark Tooth"] = 6,
			["Mutant Tooth"] = 2,
			["Fool's Gold"] = 30
		},
		Reward = { "BeastHunter", true }
	},
	TRexSkull = {
		Ingredients = {
			["Dragon Scale"] = 5,
			["Dinosaur Bones"] = 8
		},
		Reward = { "T-Rex Skull", true }
	},
	DinoHood = {
		Ingredients = {
			["Mini Tusk"] = 10,
			["Dinosaur Bones"] = 25
		},
		Reward = { "Dino Hood", true }
	},
	Dragonheart = {
		Ingredients = {
			["Dragon Egg"] = 1,
			["Dinosaur Bones"] = 6,
			["Blaze Ember"] = 15
		},
		Reward = { "Dragonheart", true }
	},
	Dragonstorm = {
		Ingredients = {
			["Dragon Egg"] = 2,
			["Dinosaur Bones"] = 10,
			["Blaze Ember"] = 30,
			["Dragon Scale"] = 5
		},
		Reward = { "Dragonstorm", true }
	},
	["Volcanic Magnet"] = {
		Ingredients = {
			["Blaze Ember"] = 15,
			["Scrap Metal"] = 10
		},
		Reward = { "Volcanic Magnet", 1 },
		MultiCraft = true
	},
	["Fortune Elixir"] = {
		Ingredients = {
			Choosable1 = {
				IsChoosable = true,
				Rarity = 0,
				Type = "Fish",
				Amount = 3
			},
			Choosable2 = {
				IsChoosable = true,
				Rarity = 1,
				Type = "Fish",
				Amount = 1
			},
			Choosable3 = {
				IsChoosable = true,
				Rarity = 2,
				Type = "Fish",
				Amount = 1
			}
		},
		Reward = { "Fortune Elixir", 1, "Potion" },
		HasKeyItem = "fortunepotion_recipe",
		MultiCraft = true
	},
	["Lava Potion"] = {
		Ingredients = {
			Choosable1 = {
				IsChoosable = true,
				Rarity = 0,
				Type = "Fish",
				Amount = 3
			}
		},
		Reward = { "Lava Potion", 1, "Potion" },
		HasKeyItem = "lavapotion_recipe",
		MultiCraft = true
	},
	["Loot Seeker"] = {
		Ingredients = {
			["Scrap Metal"] = 1,
			Choosable1 = {
				IsChoosable = true,
				Rarity = 0,
				Type = "Fish",
				Amount = 3
			}
		},
		Reward = { "Loot Seeker", 1, "Potion" },
		HasKeyItem = "lootseekerpotion_recipe",
		MultiCraft = true
	},
	["Aggro Elixir"] = {
		Ingredients = {
			["Fish Tail"] = 1,
			Choosable1 = {
				IsChoosable = true,
				Rarity = 1,
				Type = "Fish",
				Amount = 2
			}
		},
		Reward = { "Aggro Elixir", 1, "Potion" },
		HasKeyItem = "aggropotion_recipe",
		MultiCraft = true
	},
	["Berserkers Elixir"] = {
		Ingredients = {
			Leather = 1,
			Choosable1 = {
				IsChoosable = true,
				Rarity = 0,
				Type = "Fish",
				Amount = 2
			}
		},
		Reward = { "Berserkers Elixir", 1, "Potion" },
		HasKeyItem = "berserkerpotion_recipe",
		MultiCraft = true
	},
	["Fish Kebab"] = {
		Ingredients = {
			Choosable1 = {
				IsChoosable = true,
				Rarity = 0,
				Type = "Fish",
				Amount = 2
			},
			Choosable2 = {
				IsChoosable = true,
				Rarity = 1,
				Type = "Fish",
				Amount = 1
			}
		},
		Reward = { "Fish Kebab", 1, "Food" },
		HasKeyItem = "fishkebab_recipe",
		MultiCraft = true
	},
	["Oni Soul"] = {
		Ingredients = {
			Choosable1 = {
				IsChoosable = true,
				Rarity = 1,
				Type = "Fish",
				Amount = 2
			},
			Choosable2 = {
				IsChoosable = true,
				Rarity = 2,
				Type = "Fish",
				Amount = 1
			},
			["Magma Ore"] = 1
		},
		Reward = { "Oni Soul", 1, "Potion" },
		WhitelistedCampfires = { "OniCampfire" },
		Offsale = true
	},
	["Monk Potion"] = {
		Ingredients = {
			Choosable1 = {
				IsChoosable = true,
				Rarity = 2,
				Type = "Fish",
				Amount = 3
			},
			Leather = 1,
			["Scrap Metal"] = 1
		},
		Reward = { "Monk Potion", 1, "Potion" },
		WhitelistedCampfires = { "OniCampfire" },
		Offsale = true
	},
	["Invisibility Potion"] = {
		Ingredients = {
			Choosable1 = {
				IsChoosable = true,
				Rarity = 1,
				Type = "Fish",
				Amount = 2
			},
			Choosable2 = {
				IsChoosable = true,
				Rarity = 2,
				Type = "Fish",
				Amount = 1
			},
			["Yeti Fur"] = 1
		},
		Reward = { "Invisibility Potion", 1, "Potion" },
		WhitelistedCampfires = { "OniCampfire" },
		Offsale = true
	},
	["Gate Potion"] = {
		Ingredients = {
			Choosable1 = {
				IsChoosable = true,
				Rarity = rarity,
				Type = "Fish",
				Amount = 2
			},
			Choosable2 = {
				IsChoosable = true,
				Rarity = rarity3,
				Type = "Fish",
				Amount = 2
			},
			["Angel Wings"] = 1
		},
		Reward = { "Gate Potion", 1, "Potion" },
		WhitelistedCampfires = { "CelestialCampfire" },
		Offsale = true
	},
	["Fragments Elixir"] = {
		Ingredients = {
			Choosable1 = {
				IsChoosable = true,
				Rarity = rarity2,
				Type = "Fish",
				Amount = 2
			},
			["Scrap Metal"] = 1
		},
		Reward = { "Fragments Elixir", 1, "Potion" },
		WhitelistedCampfires = { "CelestialCampfire" },
		Offsale = true
	},
	["Materials Elixir"] = {
		Ingredients = {
			Choosable1 = {
				IsChoosable = true,
				Rarity = rarity,
				Type = "Fish",
				Amount = 3
			},
			Leather = 1
		},
		Reward = { "Materials Elixir", 1, "Potion" },
		WhitelistedCampfires = { "CelestialCampfire" },
		Offsale = true
	},
	["Big Head Elixir"] = {
		Ingredients = {
			Choosable1 = {
				IsChoosable = true,
				Rarity = rarity,
				Type = "Fish",
				Amount = 1
			},
			Choosable2 = {
				IsChoosable = true,
				Rarity = rarity2,
				Type = "Fish",
				Amount = 1
			}
		},
		Reward = { "Big Head Elixir", 1, "Potion" },
		WhitelistedCampfires = { "HalloweenCauldron" },
		Offsale = true
	},
	["Disguise Elixir"] = {
		Ingredients = {
			Choosable1 = {
				IsChoosable = true,
				Rarity = rarity,
				Type = "Fish",
				Amount = 1
			},
			["Fish Tail"] = 1
		},
		Reward = { "Disguise Elixir", 1, "Potion" },
		WhitelistedCampfires = { "HalloweenCauldron" },
		Offsale = true
	},
	["Lava Bomb Elixir"] = {
		Ingredients = {
			Choosable1 = {
				IsChoosable = true,
				Rarity = rarity,
				Type = "Fish",
				Amount = 1
			},
			Choosable2 = {
				IsChoosable = true,
				Rarity = rarity2,
				Type = "Fish",
				Amount = 1
			},
			Choosable3 = {
				IsChoosable = true,
				Rarity = rarity3,
				Type = "Fish",
				Amount = 1
			},
			Gunpowder = 1
		},
		Reward = { "Lava Bomb Elixir", 1, "Potion" },
		WhitelistedCampfires = { "HalloweenCauldron" },
		Offsale = true
	},
	["Pumpkin Potion"] = {
		Ingredients = {
			Choosable1 = {
				IsChoosable = true,
				Rarity = rarity3,
				Type = "Fish",
				Amount = 1
			},
			Bones = 1
		},
		Reward = { "Pumpkin Potion", 1, "Potion" },
		WhitelistedCampfires = { "HalloweenCauldron" },
		Offsale = true
	},
	["Suspicious Growth Potion"] = {
		Ingredients = {
			Choosable1 = {
				IsChoosable = true,
				Rarity = rarity2,
				Type = "Fish",
				Amount = 1
			},
			["Radioactive Material"] = 1
		},
		Reward = { "Suspicious Growth Potion", 1, "Potion" },
		WhitelistedCampfires = { "HalloweenCauldron" },
		Offsale = true
	},
	["Monster Mash Elixir"] = {
		Ingredients = {
			Choosable1 = {
				IsChoosable = true,
				Rarity = rarity,
				Type = "Fish",
				Amount = 1
			},
			Ectoplasm = 30
		},
		Reward = { "Monster Mash Elixir", 1, "Potion" },
		WhitelistedCampfires = { "HalloweenCauldron" },
		Offsale = true
	}
}
task.spawn(function()
	local RunService = game:GetService("RunService")

	if RunService:IsServer() then
		local random = Random.new()
		local jobsReplicated = game.ReplicatedStorage:FindFirstChild("JobsReplicated")
		local jobsPackage = game.ServerScriptService:FindFirstChild("JobsPackage")

		if jobsPackage and jobsReplicated then
			local module = require(jobsPackage)
			local PlayerJobsAPI = require(jobsPackage.PlayerJobsAPI)

			for k, type in module.GetReplicated().BaitData.Types do
				if not (type and type.Recipe) then
					continue
				end

				local v = {
					Ingredients = {},
					Reward = { k, 10, "Bait" },
					MultiCraft = true
				}

				for k2, v2 in type.Recipe do
					v.Ingredients[k2] = v2
				end

				local v2 = type
				local v3 = k

				function v.RequirementCallback(p)
					if v2.Vendor and v2.AnglerTrust then
						local anglerTrust = module.FishingAPI.GetAnglerTrust(p, v2.Vendor.SeaId)

						if not anglerTrust or anglerTrust < v2.AnglerTrust then
							local Global = require(game.ReplicatedStorage.Global)
							Global.TestGameWarn((`Trust was too low. {anglerTrust}<{v2.AnglerTrust}. {v3}`))
							return false
						end
					end

					return true
				end

				function v.ShouldCraftBeFreeCallback(p)
					local equippedJobToolOnCharacterOrInBackpack = PlayerJobsAPI.GetEquippedJobToolOnCharacterOrInBackpack(p)

					if equippedJobToolOnCharacterOrInBackpack and equippedJobToolOnCharacterOrInBackpack:GetAttribute("ScrollModifier_GodlikeCrafting") then
						return random:NextNumber() > 0.75
					end

					return false
				end

				CraftingRecipes[k] = v
			end
		else
			local Global = require(game.ReplicatedStorage.Global)
			Global.TestGameWarn((`JobsPackage({jobsPackage}) or JobsReplicated({jobsReplicated}) were not found.`))
		end
	end
end)
return CraftingRecipes