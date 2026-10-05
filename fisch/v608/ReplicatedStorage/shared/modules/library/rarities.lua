local Rarities = {
	Rarities = {
		Trash = {
			Name = "Trash",
			Order = 1,
			Color = Color3.fromRGB(145, 145, 145),
			ChanceGroup = "Trash",
			NoAnglerQuest = true,
			AnnounceInChat = false
		},
		Common = {
			Name = "Common",
			Order = 2,
			Color = Color3.fromRGB(142, 187, 191),
			ChanceGroup = "Common",
			AnnounceInChat = false
		},
		Uncommon = {
			Name = "Uncommon",
			Order = 3,
			Color = Color3.fromRGB(161, 255, 169),
			ChanceGroup = "Common",
			AnnounceInChat = false
		},
		Unusual = {
			Name = "Unusual",
			Order = 4,
			Color = Color3.fromRGB(192, 135, 198),
			ChanceGroup = "Rare",
			AnnounceInChat = false
		},
		Rare = {
			Name = "Rare",
			Order = 5,
			Color = Color3.fromRGB(119, 108, 181),
			ChanceGroup = "Rare",
			AnnounceInChat = false
		},
		Legendary = {
			Name = "Legendary",
			Order = 6,
			Color = Color3.fromRGB(240, 181, 109),
			BiteSoundName = "bitelegendary",
			ChanceGroup = "Legendary",
			AnglerQuestRequirement = 10,
			AnnounceInChat = true
		},
		Mythical = {
			Name = "Mythical",
			Order = 7,
			Color = Color3.fromRGB(255, 62, 120),
			BiteSoundName = "bitelegendary",
			ChanceGroup = "Mythical",
			AnglerQuestRequirement = 25,
			AnnounceInChat = true
		},
		Exotic = {
			Name = "Exotic",
			Order = 8,
			Color = Color3.fromRGB(255, 255, 255),
			ColorGradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 0.5, 1)),
				ColorSequenceKeypoint.new(0.125, Color3.fromHSV(0.125, 0.5, 1)),
				ColorSequenceKeypoint.new(0.25, Color3.fromHSV(0.25, 0.5, 1)),
				ColorSequenceKeypoint.new(0.375, Color3.fromHSV(0.375, 0.5, 1)),
				ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 0.5, 1)),
				ColorSequenceKeypoint.new(0.625, Color3.fromHSV(0.625, 0.5, 1)),
				ColorSequenceKeypoint.new(0.75, Color3.fromHSV(0.75, 0.5, 1)),
				ColorSequenceKeypoint.new(0.875, Color3.fromHSV(0.875, 0.5, 1)),
				ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 0.5, 1))
			}),
			BiteSoundName = "biteexotic",
			ChanceGroup = "Exotic",
			AnglerQuestRequirement = 50,
			AnnounceInChat = true
		},
		Secret = {
			Name = "Secret",
			Order = 9,
			Color = Color3.fromRGB(255, 255, 255),
			ColorGradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 0, 1)),
				ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0, 0, 0.25)),
				ColorSequenceKeypoint.new(1, Color3.fromHSV(0, 0, 1))
			}),
			BiteSoundName = "biteexotic",
			NoParticleLight = true,
			ChanceGroup = "Secret",
			FinalChanceDivisor = 25,
			AnglerQuestRequirement = 75,
			AnnounceInChat = true,
			HideInBestiary = true
		},
		Limited = {
			Name = "Limited",
			Order = 10,
			Color = Color3.fromRGB(74, 100, 217),
			BiteSoundName = "bitelegendary",
			ChanceGroup = "Exotic",
			AnnounceInChat = false,
			HideInBestiary = true
		},
		Relic = {
			Name = "Relic",
			Order = 11,
			Color = Color3.fromRGB(120, 255, 183),
			BiteSoundName = "bitelegendary",
			ChanceGroup = "Mythical",
			AnglerQuestRequirement = 50,
			AnnounceInChat = true
		},
		Fragment = {
			Name = "Fragment",
			Order = 12,
			Color = Color3.fromRGB(255, 63, 5),
			ChanceGroup = "Exotic",
			NoAnglerQuest = true,
			AnnounceInChat = true
		},
		Seed = {
			Name = "Seed",
			Order = 13,
			Color = Color3.fromRGB(175, 255, 47),
			BiteSoundName = "bitelegendary",
			ChanceGroup = "Exotic",
			NoAnglerQuest = true,
			AnnounceInChat = true
		},
		Gemstone = {
			Name = "Gemstone",
			Order = 14,
			Color = Color3.fromRGB(172, 57, 255),
			BiteSoundName = "bitelegendary",
			ChanceGroup = "Exotic",
			NoAnglerQuest = true,
			AnnounceInChat = true
		},
		Apex = {
			Name = "Apex",
			Order = 15,
			Color = Color3.fromRGB(255, 0, 0),
			BiteSoundName = "bitecataclysmic",
			ChanceGroup = "Exotic",
			AnglerQuestRequirement = 100,
			AnnounceInChat = true,
			HideInBestiary = true
		},
		Extinct = {
			Name = "Extinct",
			Order = 16,
			Color = Color3.fromRGB(255, 178, 178),
			NoAnglerQuest = true,
			AnnounceInChat = false,
			Protected = true,
			HideInBestiary = true
		},
		Cataclysmic = {
			Name = "Cataclysmic",
			Order = 17,
			NonFish = true,
			Color = Color3.fromRGB(255, 255, 255),
			ColorGradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(127, 24, 28)),
				ColorSequenceKeypoint.new(0.176, Color3.fromRGB(67, 21, 6)),
				ColorSequenceKeypoint.new(0.344, Color3.fromRGB(95, 35, 3)),
				ColorSequenceKeypoint.new(0.49, Color3.fromRGB(158, 40, 0)),
				ColorSequenceKeypoint.new(0.649, Color3.fromRGB(95, 35, 3)),
				ColorSequenceKeypoint.new(0.83, Color3.fromRGB(75, 22, 8)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(127, 24, 28))
			}),
			BiteSoundName = "bitecataclysmic",
			NoParticleLight = true,
			AnnounceInChat = true,
			Protected = true,
			HideInBestiary = true
		},
		Special = {
			Name = "Special",
			Order = 18,
			Color = Color3.fromRGB(255, 255, 255),
			ColorGradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 171, 255)),
				ColorSequenceKeypoint.new(0.1, Color3.fromRGB(147, 125, 255)),
				ColorSequenceKeypoint.new(0.6, Color3.fromRGB(255, 214, 117)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 171, 255))
			}),
			BiteSoundName = "bitespecial",
			NoParticleLight = true,
			AnnounceInChat = true,
			Protected = true,
			HideInBestiary = true
		},
		Nuclear = {
			Name = "Nuclear",
			Order = 19,
			NonFish = true,
			Color = Color3.fromRGB(255, 255, 255),
			ColorGradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(26, 141, 0)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(214, 196, 0)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(26, 141, 0))
			})
		},
		Unique = {
			Name = "Unique",
			Order = 20,
			NonFish = true,
			Color = Color3.fromRGB(255, 255, 255),
			ColorGradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 0)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
			})
		},
		Whistle = {
			Name = "Whistle",
			Order = 21,
			NonFish = true,
			Color = Color3.fromRGB(255, 255, 255),
			ColorGradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(230, 230, 230)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
			})
		},
		Mirror = {
			Name = "Mirror",
			Order = 22,
			NonFish = true,
			Color = Color3.fromRGB(255, 255, 255),
			ColorGradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(183, 214, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
			})
		},
		["Divine Secret"] = {
			Name = "Divine Secret",
			Order = 23,
			Color = Color3.fromRGB(255, 255, 255),
			ColorGradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(117, 117, 255)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(224, 188, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(138, 92, 255))
			}),
			BiteSoundName = "bitedivine",
			NoParticleLight = true,
			NoAnglerQuest = true,
			HasSerial = true,
			Protected = true,
			AnnounceInChat = true,
			HideInBestiary = true
		}
	},
	OrderedRarities = {},
	ChanceGroups = {
		Trash = {
			Name = "Trash",
			Order = 1,
			BaseChance = 100,
			LuckFactor = -35,
			RoamerChanceMultiplier = 2
		},
		Common = {
			Name = "Common",
			Order = 2,
			BaseChance = 200,
			LuckFactor = -20,
			RoamerChanceMultiplier = 10
		},
		Rare = {
			Name = "Rare",
			Order = 3,
			BaseChance = 35,
			LuckFactor = -1.5,
			RoamerChanceMultiplier = 10
		},
		Legendary = {
			Name = "Legendary",
			Order = 4,
			BaseChance = 10,
			LuckFactor = 1.27,
			RoamerChanceMultiplier = 5
		},
		Mythical = {
			Name = "Mythical",
			Order = 5,
			BaseChance = 0.1,
			LuckFactor = 1.5,
			RoamerChanceMultiplier = 5
		},
		Exotic = {
			Name = "Exotic",
			Order = 6,
			BaseChance = 0.01,
			LuckFactor = 0.5,
			RoamerChanceMultiplier = 3
		},
		Secret = {
			Name = "Secret",
			Order = 7,
			BaseChance = 0.01,
			LuckFactor = 0.5,
			RoamerChanceMultiplier = 5
		}
	},
	OrderedChanceGroups = {},
	OrderedRarityNames = {},
	StaticColors = {},
	GradientColors = {},
	AnyColors = {}
}

for _, rarity in Rarities.Rarities do
	if Rarities.OrderedRarities[rarity.Order] then
		warn((`Rarity order collission between {rarity.Name} and {Rarities.OrderedRarities[rarity.Order].Name}!`))
	else
		Rarities.OrderedRarities[rarity.Order] = rarity
		Rarities.OrderedRarityNames[rarity.Order] = rarity.Name
		Rarities.StaticColors[rarity.Name] = rarity.Color
		Rarities.GradientColors[rarity.Name] = rarity.ColorGradient or ColorSequence.new(rarity.Color)
		Rarities.AnyColors[rarity.Name] = rarity.ColorGradient or rarity.Color
	end
end

for _, chanceGroup in Rarities.ChanceGroups do
	if Rarities.OrderedChanceGroups[chanceGroup.Order] then
		warn((`Chance Group order collission between {chanceGroup.Name} and {Rarities.OrderedChanceGroups[chanceGroup.Order].Name}!`))
	else
		Rarities.OrderedChanceGroups[chanceGroup.Order] = chanceGroup
	end
end

return Rarities