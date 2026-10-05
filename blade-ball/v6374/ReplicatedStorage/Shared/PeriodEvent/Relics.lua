local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)(script.Parent.Types)
return {
	TheRising = {
		relics = {
			Common = {
				Color = Color3.fromRGB(44, 135, 255)
			},
			Rare = {
				Color = Color3.fromRGB(149, 57, 255)
			}
		},
		ingredients = {
			AbyssalRoots = {
				Id = "AbyssalRoots",
				DisplayName = "Abyssal Roots",
				Icon = "",
				Relic = "Common"
			},
			SoulEmbers = {
				Id = "SoulEmbers",
				DisplayName = "Soul Embers",
				Icon = "",
				Relic = "Common"
			},
			ObsidianTears = {
				Id = "ObsidianTears",
				DisplayName = "Obsidian Tears",
				Icon = "",
				Relic = "Rare"
			}
		}
	},
	BlizzardBreakout = {
		relics = {
			Common = {
				Color = Color3.fromRGB(44, 135, 255)
			},
			Rare = {
				Color = Color3.fromRGB(149, 57, 255)
			},
			Legendary = {
				Color = Color3.fromRGB(255, 186, 74)
			},
			Secret = {
				Color = Color3.fromRGB(0, 0, 0)
			}
		},
		ingredients = {
			FrostShards = {
				Id = "FrostShards",
				DisplayName = "Frost Shards",
				Icon = "",
				Relic = "Common"
			},
			SnowmenEyes = {
				Id = "SnowmenEyes",
				DisplayName = "Snowmen Eyes",
				Icon = "",
				Relic = "Common"
			},
			GlacierCores = {
				Id = "GlacierCores",
				DisplayName = "Glacier Cores",
				Icon = "",
				Relic = "Rare"
			}
		}
	},
	HolidayHeist = {
		relics = {
			Common = {
				Color = Color3.fromRGB(44, 135, 255)
			},
			Rare = {
				Color = Color3.fromRGB(149, 57, 255)
			},
			Legendary = {
				Color = Color3.fromRGB(255, 186, 74)
			},
			Secret = {
				Color = Color3.fromRGB(0, 0, 0)
			}
		},
		ingredients = {
			CandyWrappers = {
				Id = "CandyWrappers",
				DisplayName = "Candy Wrappers",
				Icon = "",
				Relic = "Common"
			},
			BrokenNutcracker = {
				Id = "BrokenNutcracker",
				DisplayName = "Broken Nutcracker",
				Icon = "",
				Relic = "Common"
			},
			ChristmasPresent = {
				Id = "ChristmasPresent",
				DisplayName = "Christmas Present",
				Icon = "",
				Relic = "Rare"
			}
		}
	},
	GalacticCollapse = {
		relics = {
			Common = {
				Color = Color3.fromRGB(44, 135, 255)
			},
			Rare = {
				Color = Color3.fromRGB(149, 57, 255)
			},
			Legendary = {
				Color = Color3.fromRGB(255, 186, 74)
			}
		},
		ingredients = {
			PulsarFragments = {
				Id = "PulsarFragments",
				DisplayName = "Pulsar Fragments",
				Icon = "",
				Relic = "Common"
			},
			RiftTendrils = {
				Id = "RiftTendrils",
				DisplayName = "Rift Tendrils",
				Icon = "",
				Relic = "Rare"
			},
			SingularityTears = {
				Id = "SingularityTears",
				DisplayName = "Singularity Tears",
				Icon = "",
				Relic = "Legendary"
			}
		}
	},
	SerpentBreakout = {
		relics = {
			Common = {
				Color = Color3.fromRGB(44, 135, 255)
			},
			Rare = {
				Color = Color3.fromRGB(149, 57, 255)
			},
			Legendary = {
				Color = Color3.fromRGB(255, 186, 74)
			},
			Secret = {
				Color = Color3.fromRGB(0, 0, 0)
			}
		},
		ingredients = {
			SerpentScales = {
				Id = "SerpentScales",
				DisplayName = "Serpent Scales",
				Icon = "",
				Relic = "Common"
			},
			SerpentEyes = {
				Id = "SerpentEyes",
				DisplayName = "Serpent Eyes",
				Icon = "",
				Relic = "Common"
			},
			VenomCores = {
				Id = "VenomCores",
				DisplayName = "Venom Cores",
				Icon = "",
				Relic = "Rare"
			}
		}
	}
}