local recipebuilder = require(script.recipebuilder)
return {
	["Titanium Rod"] = recipebuilder.new():SetName("Titanium Rod"):SetHint("Crafted from parts forged within The Deep"):SetLevel(250):SetItems(
		{ "Titanium Shaft", 1 },
		{ "Titanium Reel", 1 },
		{ "Refined Scrap", 5 }
	):SetCost(200000):SetOutput("Titanium Rod"):SetType("Rod"):SetCraftOnce(true):SetPremium(false):Build(),
	["Cusk Purger"] = recipebuilder.new():SetName("Cusk Purger"):SetHint("Crafted from the remains of the Monstrous Cusk"):SetLevel(400):SetItems(
		{ "Monstrous Cusk Tooth", 3 },
		{ "Line of the Deep", 1 },
		{ "Refined Scrap", 3 },
		{ "Hardened Chitin", 3 },
		{ "Abyssal Bio-Fluid", 3 },
		{ "Radiant Prism Scale", 3 },
		{ "Ancient Bone", 3 }
	):SetCost(750000):SetOutput("Cusk Purger"):SetType("Rod"):SetCraftOnce(true):SetPremium(false):Build(),
	["Lucid Rod"] = recipebuilder.new():SetName("Lucid Rod"):SetHint("Materials hidden within the Cultist Lair"):SetItems(
		{ "Lunar Thread", 1 },
		{ "Lucid Reel", 1 },
		{ "Scrap Metal", 1, "Cursed Touch" }
	):SetOutput("Lucid Rod"):SetLevel(50):SetCost(80000):SetType("Rod"):SetCraftOnce(true):SetPremium(false):Build(),
	["Vineweaver Rod"] = recipebuilder.new():SetName("Vineweaver Rod"):SetHint("Materials hidden within the Lost Jungle"):SetItems(
		{ "Driftwood", 1, "Vined" },
		{ "Vine Line", 1 },
		{ "Mauve Pearl", 1, "Vined" }
	):SetOutput("Vineweaver Rod"):SetLevel(70):SetCost(150000):SetType("Rod"):SetCraftOnce(true):SetPremium(false):Build(),
	["Toxic Spire Rod"] = recipebuilder.new():SetName("Toxic Spire Rod"):SetHint("Materials hidden within the Lost Jungle"):SetItems(
		{ "Driftwood", 1, "Poisoned" },
		{ "Toxic Core", 1 },
		{ "Murky Thread", 1 }
	):SetOutput("Toxic Spire Rod"):SetLevel(90):SetCost(170000):SetType("Rod"):SetCraftOnce(true):SetPremium(false):Build(),
	["Elder Mossripper"] = recipebuilder.new():SetName("Elder Mossripper"):SetHint("Crafted from materials hidden within the Lost Jungle"):SetItems(
		{ "Elder Mossjaw", 1 },
		{ "Mossy Core", 1 },
		{ "Golden Sea Pearl", 1, "Shrouded" }
	):SetOutput("Elder Mossripper"):SetLevel(350):SetCost(2500000):SetType("Rod"):SetCraftOnce(true):SetPremium(false):Build(),
	["Gardenkeeper Rod"] = recipebuilder.new():SetName("Gardenkeeper Rod"):SetHint("Crafted from flowers within the Living Garden"):SetItems(
		{ "Violet Lotus", 1 },
		{ "Cyan Lotus", 1 },
		{ "Canary Lotus", 1 },
		{ "Oversized Leaf", 10 }
	):SetOutput("Gardenkeeper Rod"):SetLevel(150):SetCost(150000):SetType("Rod"):SetCraftOnce(true):SetPremium(false):Build(),
	["Toxinburst Rod"] = recipebuilder.new():SetName("Toxinburst Rod"):SetHint("Crafted from parts within the Toxic Grove"):SetItems(
		{ "Toxinburst Handle", 1 },
		{ "Toxinburst Line", 1 },
		{ "Toxinburst Shaft", 1 },
		{ "Toxic Jellymass", 1 }
	):SetOutput("Toxinburst Rod"):SetLevel(150):SetCost(185000):SetType("Rod"):SetCraftOnce(true):SetPremium(false):Build(),
	["Evil Pitchfork"] = recipebuilder.new():SetName("Evil Pitchfork"):SetHint("Unlock this recipe in the Crimson Cavern"):SetItems({
		"Evil Sigil",
		1
	}):SetOutput("Evil Pitchfork"):SetLevel(666):SetCost(1666000):SetType("Rod"):SetCraftOnce(true):SetPremium(false):Build(),
	["Precision Rod"] = recipebuilder.new():SetName("Precision Rod"):SetHint("Reach Level 5 to unlock this recipe"):SetLevel(25):SetItems(
		{ "Amethyst", 1 },
		{ "Driftwood", 2 },
		{ "Magic Thread", 1 }
	):SetCost(0):SetOutput("Precision Rod"):SetType("Rod"):SetCraftOnce(true):SetPremium(false):Build(),
	["Wisdom Rod"] = recipebuilder.new():SetName("Wisdom Rod"):SetHint("Reach Level 50 to unlock this recipe"):SetLevel(50):SetItems(
		{ "Ruby", 1 },
		{ "Driftwood", 2, "Mythical" },
		{ "Magic Thread", 1 }
	):SetCost(0):SetOutput("Wisdom Rod"):SetType("Rod"):SetCraftOnce(true):SetPremium(false):Build(),
	["Resourceful Rod"] = recipebuilder.new():SetName("Resourceful Rod"):SetHint("Reach Level 50 to unlock this recipe"):SetLevel(50):SetItems(
		{ "Amethyst", 3 },
		{ "Driftwood", 2, "Lunar" },
		{ "Magic Thread", 1 }
	):SetCost(0):SetOutput("Resourceful Rod"):SetType("Rod"):SetCraftOnce(true):SetPremium(false):Build(),
	["Seasons Rod"] = recipebuilder.new():SetName("Seasons Rod"):SetHint("Reach Level 40 to unlock this recipe"):SetLevel(40):SetItems(
		{ "Opal", 2 },
		{ "Driftwood", 3, "Frozen" },
		{ "Magic Thread", 1 }
	):SetCost(0):SetOutput("Seasons Rod"):SetType("Rod"):SetCraftOnce(true):SetPremium(false):Build(),
	["Riptide Rod"] = recipebuilder.new():SetName("Riptide Rod"):SetHint("Reach Level 30 to unlock this recipe"):SetLevel(30):SetItems(
		{ "Ruby", 3 },
		{ "Driftwood", 3, "Atlantean" },
		{ "Magic Thread", 1 }
	):SetCost(0):SetOutput("Riptide Rod"):SetType("Rod"):SetCraftOnce(true):SetPremium(false):Build(),
	["Voyager Rod"] = recipebuilder.new():SetName("Voyager Rod"):SetHint("Reach Level 80 to unlock this recipe"):SetLevel(80):SetItems(
		{ "Opal", 3 },
		{ "Void Wood", 3 },
		{ "Magic Thread", 1 }
	):SetCost(0):SetOutput("Voyager Rod"):SetType("Rod"):SetCraftOnce(true):SetPremium(false):Build(),
	["The Lost Rod"] = recipebuilder.new():SetName("The Lost Rod"):SetHint("Reach Level 100 to unlock this recipe"):SetLevel(100):SetItems(
		{ "Lapis Lazuli", 3 },
		{ "Ancient Wood", 3 },
		{ "Ancient Thread", 1 }
	):SetCost(0):SetOutput("The Lost Rod"):SetType("Rod"):SetCraftOnce(true):SetPremium(false):Build(),
	["Celestial Rod"] = recipebuilder.new():SetName("Celestial Rod"):SetHint("Reach Level 350 to unlock this recipe"):SetLevel(250):SetItems(
		{ "Moonstone", 2 },
		{ "Moon Wood", 3 },
		{ "Ancient Thread", 1 }
	):SetCost(0):SetOutput("Celestial Rod"):SetType("Rod"):SetCraftOnce(true):SetPremium(false):Build(),
	["Rod Of The Eternal King"] = recipebuilder.new():SetName("Rod Of The Eternal King"):SetHint("Reach Level 400 to unlock this recipe"):SetLevel(400):SetItems(
		{ "Golden Sea Pearl", 2 },
		{ "Inferno Wood", 3 },
		{ "Lunar Thread", 1 }
	):SetCost(0):SetOutput("Rod Of The Eternal King"):SetType("Rod"):SetCraftOnce(true):SetPremium(false):Build(),
	["Rod Of The Forgotten Fang"] = recipebuilder.new():SetName("Rod Of The Forgotten Fang"):SetHint("Reach Level 700 to unlock this recipe"):SetLevel(450):SetItems(
		{ "Meg's Fang", 2 },
		{ "Meg's Spine", 2 },
		{ "Lunar Thread", 1 }
	):SetCost(500000):SetOutput("Rod Of The Forgotten Fang"):SetType("Rod"):SetCraftOnce(true):SetPremium(false):Build(),
	Spiritbinder = recipebuilder.new():SetName("Spiritbinder"):SetHint("Reach Level 500 to unlock this recipe"):SetLevel(500):SetItems(
		{ "Sea Mine", 2, "Spirit" },
		{ "Speed Core", 3, "Spirit" },
		{ "Lunar Thread", 3 }
	):SetCost(500000):SetOutput("Spiritbinder"):SetType("Rod"):SetCraftOnce(true):SetPremium(false):Build(),
	["Dead Man's Rod"] = recipebuilder.new():SetName("Dead Man's Rod"):SetHint("???"):SetLevel(1000):SetItems(
		{ "Dead Man's Tentacle", 1 },
		{ "Dead Man's Treasure", 1 },
		{ "Dead Man's Wood", 1 },
		{ "Seaweed", 1, "Putrid" }
	):SetCost(5000000):SetOutput("Dead Man's Rod"):SetType("Rod"):SetCraftOnce(true):SetPremium(false):Build(),
	Tidemourner = recipebuilder.new():SetName("Tidemourner"):SetHint("Reach Level 200 to unlock this recipe"):SetLevel(200):SetItems(
		{ "Tide Essence", 3 },
		{ "Iron Chunk", 5 },
		{ "Tidemourner Head", 1 },
		{ "Moonstone", 1, "Mourned" }
	):SetCost(1200000):SetOutput("Tidemourner"):SetType("Rod"):SetCraftOnce(true):SetPremium(false):Build(),
	Requiem = recipebuilder.new():SetName("Requiem"):SetHint("Reach Level 1000 to unlock this recipe"):SetLevel(1000):SetItems(
		{ "Requis Essence", 5 },
		{ "Requiem Core", 1 },
		{ "Awakened Omnithal", 1 },
		{ "Plesiosaur", 1, "Fossilized" }
	):SetCost(15000000):SetOutput("Requiem"):SetType("Rod"):SetCraftOnce(true):SetPremium(false):Build(),
	["Anchor n' Chain"] = recipebuilder.new():SetName("Anchor n' Chain"):SetHint("Reach Level 25 to unlock this recipe"):SetLevel(25):SetItems(
		{ "Anchor", 1 },
		{ "Scrap Metal", 10 }
	):SetCost(5000):SetOutput("Anchor n' Chain"):SetType("Rod"):SetCraftOnce(true):SetPremium(false):Build(),
	["Scarlet Spincaster Rod"] = recipebuilder.new():SetName("Scarlet Spincaster Rod"):SetHint("Reach Level 100 to unlock this recipe"):SetLevel(100):SetItems(
		{ "Driftwood", 3, "Hexed" },
		{ "Colossal Blue Dragon", 1, "Hexed" }
	):SetCost(15000):SetOutput("Scarlet Spincaster Rod"):SetType("Rod"):SetCraftOnce(true):SetPremium(false):Build(),
	Terrotrapper = recipebuilder.new():SetName("Terrotrapper"):SetHint("Reach level 200 to unlock this recipe"):SetLevel(200):SetItems(
		{ "Photic Terrosunder", 1 },
		{ "Terrosunder Skull", 1, "Marrow" },
		{ "Opal", 1, "Fossilized" },
		{ "Dune Thread", 1 }
	):SetCost(100000):SetOutput("Terrotrapper"):SetType("Rod"):SetCraftOnce(true):SetPremium(false):Build(),
	["Marrow Rod"] = recipebuilder.new():SetName("Marrow Rod"):SetHint("Reach level 200 to unlock this recipe"):SetLevel(200):SetItems(
		{ "Mysterious Skull", 1 },
		{ "Mysterious Spine", 1 },
		{ "Mysterious Fang", 1 }
	):SetCost(100000):SetOutput("Marrow Rod"):SetType("Rod"):SetCraftOnce(true):SetPremium(false):Build(),
	["Abaia's Spite"] = recipebuilder.new():SetName("Abaia's Spite"):SetHint("Bound from the squall that Abaia rides"):SetLevel(850):SetItems(
		{ "Line of the Skies", 1 },
		{ "Abaia", 1, "Squalled" },
		{ "Ancestral Abaia", 1 },
		{ "Empyrean Relic", 1, "Petrified" }
	):SetCost(750000):SetOutput("Abaia's Spite"):SetType("Rod"):SetCraftOnce(true):SetPremium(false):Build()
}