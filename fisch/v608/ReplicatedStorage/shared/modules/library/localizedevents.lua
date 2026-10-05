local Localizedevents = {
	AbsoluteDarkness = {
		DisplayName = "Absolute Darkness",
		Icon = "rbxassetid://123229388990184",
		IconColor = Color3.fromRGB(122, 193, 46),
		Tooltip = "The Depths have grown darker...",
		AttributeName = "DepthsAbsoluteDarkness",
		ActiveZones = { "The Depths" }
	},
	NectarBloom = {
		DisplayName = "Nectar Bloom",
		Icon = "rbxassetid://112430802245624",
		IconColor = Color3.fromRGB(255, 219, 75),
		Tooltip = "The hive has bloomed with brightness!",
		AttributeName = "NectarBloom",
		ActiveZones = { "Nectar Den" }
	},
	BrineStorm = {
		DisplayName = "Brine Storm",
		Icon = "rbxassetid://116675168007205",
		IconColor = Color3.fromRGB(52, 255, 143),
		Tooltip = "Unique fish are now appearing! Lure speed is halved...",
		AttributeName = "BrineStormActive",
		ActiveZones = { "Brine Pool", "Desolate Brine Pool" }
	},
	DripstoneCollapse = {
		DisplayName = "Dripstone Collapse",
		IconColor = Color3.fromRGB(255, 195, 167),
		Icon = "rbxassetid://115498780671360",
		Tooltip = "Watch your head!",
		AttributeName = "TidefallDripstoneCollapse",
		ActiveZones = {
			"Tidefall",
			"Coral Bastion",
			"Sunken Reliquary",
			"Collapsed Ruins",
			"Crowned Ruins",
			"Inner Tidefall Castle",
			"Tidefall Castle"
		}
	},
	PowerBurst = {
		DisplayName = "Power Burst",
		Icon = "rbxassetid://101408778873592",
		IconColor = Color3.fromRGB(184, 134, 255),
		Tooltip = "The pillars begin to resonate...",
		AttributeName = "PowerBurstActive",
		ActiveZones = { "Keepers Altar", "Enchanted Crevice" }
	},
	Earthquake = {
		DisplayName = "Earthquake",
		Icon = "rbxassetid://73446258484932",
		IconColor = Color3.fromRGB(255, 142, 44),
		Tooltip = "Cataclysmic deep sea fish are awakening...",
		AttributeName = "EarthquakeActive",
		ActiveZones = { "Ocean" }
	},
	Eruption = {
		DisplayName = "Eruption",
		Icon = "rbxassetid://73601863332201",
		IconColor = Color3.fromRGB(255, 109, 41),
		Tooltip = "Ashclaw stirs within the magma! Catch it before it's too late!",
		AttributeName = "EruptionActive",
		ActiveZones = { "Roslit Volcano" }
	},
	Blizzard = {
		DisplayName = "Blizzard",
		Icon = "rbxassetid://102766454015069",
		IconColor = Color3.fromRGB(134, 229, 255),
		AttributeName = "BlizzardActive",
		ActiveZones = {
			"Northern Summit",
			"Overgrowth Caves",
			"Frigid Cavern",
			"Cryogenic Canal",
			"Glacial Grotto",
			"Boreal Pines",
			"Crystal Fissure"
		}
	},
	Avalanche = {
		DisplayName = "Avalanche",
		Icon = "rbxassetid://78034344903795",
		IconColor = Color3.fromRGB(161, 235, 255),
		Tooltip = "Watch out for falling debris!",
		AttributeName = "Avalanche",
		ActiveZones = {
			"Northern Summit",
			"Overgrowth Caves",
			"Frigid Cavern",
			"Cryogenic Canal",
			"Glacial Grotto"
		}
	},
	ZeusStorm = {
		DisplayName = "Zeus's Storm",
		Icon = "rbxassetid://129520001623089",
		IconColor = Color3.fromRGB(255, 243, 111),
		Tooltip = "The Lightning grows restless",
		AttributeName = "ZeusStormActive",
		ActiveZones = {
			"Atlantis",
			"Zeus Trial",
			"Zeus's Trial",
			"Zeus's Sanctuary",
			"Zeus's Thunder of Chaos"
		}
	},
	PoseidonWrath = {
		DisplayName = "Poseidon's Wrath",
		Icon = "rbxassetid://98653109149109",
		IconColor = Color3.fromRGB(121, 175, 255),
		AttributeName = "PoseidonWrathActive",
		ActiveZones = {
			"Atlantis",
			"Poseidon Temple",
			"Poseidon Trial",
			"Poseidon's Storm of Floods",
			"Kraken Lair"
		}
	},
	WarSurge = {
		DisplayName = "War Surge",
		Icon = "rbxassetid://103264238918635",
		IconColor = Color3.fromRGB(255, 53, 73),
		Tooltip = "+50 Luck, -40 Resilience\nExclusive fish have been awakened!",
		AttributeName = "WarSurgeActive",
		ActiveZones = { "Bellona's Frenzy of War" }
	},
	SolarChorus = {
		DisplayName = "Solar Chorus",
		Icon = "rbxassetid://116026742691439",
		IconColor = Color3.fromRGB(255, 191, 88),
		Tooltip = "+25% Lure and Progress Speed while fishing in rays of light",
		AttributeName = "SolarChorusActive",
		ActiveZones = { "Apollo's Song of Light" }
	},
	StormFlood = {
		DisplayName = "Storm Flood",
		Icon = "rbxassetid://139257480425991",
		IconColor = Color3.fromRGB(73, 167, 255),
		Tooltip = "The waters are rising!",
		AttributeName = "StormFloodActive",
		ActiveZones = { "Poseidon's Storm of Floods" }
	},
	SoulScourge = {
		DisplayName = "Soul Scourge",
		Icon = "rbxassetid://134317873055882",
		IconColor = Color3.fromRGB(107, 79, 191),
		Tooltip = "The dark spirits surge...\n0.3× Resilience and Control!",
		AttributeName = "SoulScourgeActive",
		ActiveZones = { "Hades' Underworld of Indefinite" }
	},
	WispHaunt = {
		DisplayName = "Wisp Haunt",
		Icon = "rbxassetid://88882599257596",
		IconColor = Color3.fromRGB(55, 255, 155),
		Tooltip = "The spirits have converged!",
		AttributeName = "WispHauntActive",
		ActiveZones = { "Hades' Underworld of Indefinite" }
	},
	DustStorm = {
		DisplayName = "Dust Storm",
		Icon = "rbxassetid://75918805572575",
		IconColor = Color3.fromRGB(255, 219, 156),
		Tooltip = "2× luck; Unique fish are appearing!",
		AttributeName = "DustStormActive",
		ActiveZones = {
			"Drylands",
			"Dunehaven",
			"The Sunken Reservoir",
			"The Claypans"
		}
	},
	TorrentialRain = {
		DisplayName = "Torrential Rain",
		Icon = "rbxassetid://128331198826806",
		IconColor = Color3.fromRGB(47, 83, 159),
		Tooltip = "The Claypans are being filled!",
		AttributeName = "TorrentialRainActive",
		ActiveZones = {
			"Drylands",
			"Dunehaven",
			"The Sunken Reservoir",
			"The Claypans"
		}
	}
}

for k, v in Localizedevents do
	v.Name = k
end

return Localizedevents