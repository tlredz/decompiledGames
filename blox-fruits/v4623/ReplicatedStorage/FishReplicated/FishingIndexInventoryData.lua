local fishReplicated = game.ReplicatedStorage.FishReplicated
local FishEnum = require(fishReplicated.FishEnum)
local probabilities = FishEnum.Probabilities
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local fishIndex = {}
local _ = {
	Common = 0,
	Uncommon = 1,
	Rare = 2,
	Legendary = 3,
	Mythical = 4
}
local ItemId = require(game.ReplicatedStorage.Economy.ItemId)

local function addFish(name, p2)
	local v2 = {
		Name = name
	}

	if p2 then
		for k, v3 in p2 do
			v2[k] = v3
		end

		if p2.IsNotAFish then
			fishIndex[name] = v2
			return
		end
	end

	local unwrapped = ItemId.getId(name, "Fish"):unwrap()

	if fishIndex[unwrapped] ~= nil then
		error((`{name} already has data`))
	end

	fishIndex[unwrapped] = v2
end

addFish("Tuna", {
	Tags = { "Food", "Fish" },
	RequiredBait = nil,
	RequiredBaitRarity = 0,
	Rarity = 0,
	MinWeight = 5,
	MaxWeight = 40,
	BaseChance = probabilities.Medium
})
addFish("Carp", {
	Tags = { "Food", "Fish" },
	RequiredBait = nil,
	RequiredBaitRarity = 0,
	Rarity = 0,
	MinWeight = 2,
	MaxWeight = 19,
	BaseChance = probabilities.High
})
addFish("Catfish", {
	Tags = { "Food", "Fish" },
	RequiredBait = nil,
	RequiredBaitRarity = 0,
	Rarity = 0,
	MinWeight = 5,
	MaxWeight = 37,
	BaseChance = probabilities.Low
})
addFish("Flatfish", {
	Tags = { "Food", "Fish" },
	RequiredBait = nil,
	RequiredBaitRarity = 0,
	Rarity = 1,
	MinWeight = 7,
	MaxWeight = 50,
	BaseChance = probabilities.Low
})
addFish("Goldfish", {
	Tags = { "Food", "Fish" },
	RequiredBait = nil,
	RequiredBaitRarity = 0,
	Rarity = 0,
	MinWeight = 2,
	MaxWeight = 20,
	BaseChance = probabilities.Medium
})
addFish("Angelfish", {
	Tags = { "Food", "Fish" },
	RequiredBait = nil,
	RequiredBaitRarity = 0,
	Rarity = 1,
	MinWeight = 6,
	MaxWeight = 46,
	BaseChance = probabilities.Medium
})
addFish("Tidegill", {
	Tags = { "Food", "Fish", "Aggressive" },
	RequiredBait = nil,
	RequiredBaitRarity = 0,
	Rarity = 0,
	MinWeight = 3,
	MaxWeight = 27,
	Elusiveness = 2,
	Aggressiveness = 2,
	BaseChance = probabilities.Medium
})
addFish("Redfin", {
	Tags = { "Food", "Fish" },
	RequiredBait = nil,
	RequiredBaitRarity = 0,
	Rarity = 0,
	MinWeight = 4,
	MaxWeight = 30,
	BaseChance = probabilities.High
})
addFish("Clownfish", {
	Tags = { "Food", "Fish", "Kelp" },
	RequiredBait = nil,
	RequiredBaitRarity = 0,
	Rarity = 1,
	MinWeight = 5,
	MaxWeight = 37,
	BaseChance = probabilities.Low
})
addFish("Grouper", {
	Tags = { "Food", "Fish" },
	RequiredBait = nil,
	RequiredBaitRarity = 0,
	Rarity = 0,
	MinWeight = 6,
	MaxWeight = 44,
	BaseChance = probabilities.Medium
})
addFish("Parrotfish", {
	Tags = { "Food", "Fish", "Kelp" },
	RequiredBait = { "Kelp Bait" },
	RequiredBaitRarity = 0,
	Rarity = 1,
	MinWeight = 7,
	MaxWeight = 48
})
addFish("Mossback", {
	Tags = { "Food", "Fish", "Kelp" },
	RequiredBait = nil,
	RequiredBaitRarity = 0,
	Rarity = 0,
	MinWeight = 5,
	MaxWeight = 38,
	BaseChance = probabilities.Low
})
addFish("Sand Bass", {
	Tags = { "Food", "Fish" },
	RequiredBait = nil,
	RequiredBaitRarity = 0,
	Rarity = 0,
	MinWeight = 5,
	MaxWeight = 37,
	BaseChance = probabilities.Low
})
addFish("Amber Trout", {
	Tags = { "Food", "Fish" },
	RequiredBait = nil,
	RequiredBaitRarity = 0,
	Rarity = 1,
	MinWeight = 6,
	MaxWeight = 44,
	BaseChance = probabilities.Low
})
addFish("Molten Trout", {
	Tags = { "Fish", "Lava" },
	RequiredBait = nil,
	RequiredBaitRarity = 2,
	Rarity = 2,
	MinWeight = 5,
	MaxWeight = 39
})
addFish("Leafy Trout", {
	Tags = { "Fish", "Kelp" },
	RequiredBait = { "Kelp Bait" },
	RequiredBaitRarity = 2,
	Rarity = 2,
	MinWeight = 6,
	MaxWeight = 42
})
addFish("Kelp Bass", {
	Tags = { "Food", "Fish", "Kelp" },
	RequiredBait = nil,
	RequiredBaitRarity = 0,
	Rarity = 1,
	MinWeight = 5,
	MaxWeight = 35,
	BaseChance = probabilities.Low
})
addFish("Gliderfish", {
	Tags = { "Food", "Fish", "Winged" },
	RequiredBait = nil,
	RequiredBaitRarity = 0,
	Rarity = 2,
	MinWeight = 5,
	MaxWeight = 36,
	Elusiveness = 2,
	Aggressiveness = 1,
	BaseChance = probabilities.VeryLow
})
addFish("Levi", {
	Tags = { "Food", "Fish", "Serpent" },
	RequiredBait = { "Frozen Bait" },
	RequiredBaitRarity = 0,
	Rarity = 4,
	MinWeight = 13,
	MaxWeight = 150,
	Elusiveness = 2,
	Aggressiveness = 1,
	onCaughtCallbackName = "Levi"
})
addFish("Pufferfish", {
	Tags = { "Food", "Fish" },
	RequiredBait = nil,
	RequiredBaitRarity = 0,
	Rarity = 1,
	MinWeight = 5,
	MaxWeight = 38,
	Aggressiveness = 2,
	BaseChance = probabilities.VeryLow
})
addFish("Angler", {
	Tags = {
		"Food",
		"Abyssal",
		"Fish",
		"Carnivore"
	},
	RequiredBait = { "Abyssal Bait" },
	RequiredBaitRarity = 0,
	Rarity = 3,
	MinWeight = 4,
	MaxWeight = 32
})
addFish("Candyfish", {
	Tags = { "Food", "Fish", "Sweet" },
	RequiredBait = nil,
	RequiredBaitRarity = 0,
	Rarity = 2,
	MinWeight = 6,
	MaxWeight = 47
})
addFish("Bullfish", {
	Tags = { "Fish", "Aggressive", "Carnivore" },
	RequiredBait = { "Carnivore Bait" },
	RequiredBaitRarity = 0,
	Rarity = 1,
	MinWeight = 4,
	MaxWeight = 33,
	Aggressiveness = 7
})
addFish("Sea Sturgeon", {
	Tags = { "Fish" },
	RequiredBait = nil,
	RequiredBaitRarity = 0,
	Rarity = 0,
	MinWeight = 5,
	MaxWeight = 37,
	Aggressiveness = 2,
	BaseChance = probabilities.Medium
})
addFish("Rock Dweller", {
	Tags = {
		"Food",
		"Fish",
		"Rock",
		"Aggressive"
	},
	RequiredBait = nil,
	RequiredBaitRarity = 1,
	Rarity = 3,
	MinWeight = 21,
	MaxWeight = 145,
	Aggressiveness = 2
})
addFish("Gravelhead Shark", {
	Tags = {
		"Food",
		"Fish",
		"Rock",
		"Aggressive",
		"Carnivore"
	},
	RequiredBait = { "Carnivore Bait" },
	RequiredBaitRarity = 3,
	Rarity = 4,
	MinWeight = 148,
	MaxWeight = 989,
	Aggressiveness = 5
})
addFish("Ghostfish", {
	Tags = { "Food", "Abyssal", "Fish" },
	RequiredBait = { "Abyssal Bait" },
	RequiredBaitRarity = 2,
	Rarity = 2,
	MinWeight = 6,
	MaxWeight = 41,
	Elusiveness = 3
})
addFish("Frostjaw", {
	Tags = {
		"Fish",
		"Frozen",
		"Aggressive",
		"Carnivore"
	},
	RequiredBait = { "Frozen Bait" },
	RequiredBaitRarity = 1,
	Rarity = 3,
	MinWeight = 25,
	MaxWeight = 172,
	Aggressiveness = 3
})
addFish("Deepglow Oarfish", {
	Tags = { "Fish", "Abyssal", "Aggressive" },
	RequiredBait = { "Abyssal Bait" },
	RequiredBaitRarity = 1,
	Rarity = 3,
	MinWeight = 18,
	MaxWeight = 121,
	Elusiveness = 3
})
addFish("Barracuda", {
	Tags = { "Fish", "Aggressive", "Carnivore" },
	RequiredBait = nil,
	RequiredBaitRarity = 1,
	Rarity = 1,
	MinWeight = 5,
	MaxWeight = 35,
	Aggressiveness = 3
})
addFish("Saltwater Salmon", {
	Tags = { "Food", "Fish" },
	RequiredBait = nil,
	RequiredBaitRarity = 0,
	Rarity = 0,
	MinWeight = 5,
	MaxWeight = 40,
	BaseChance = probabilities.Medium
})
addFish("Azure Marlin", {
	Tags = { "Fish", "Aggressive" },
	RequiredBait = nil,
	RequiredBaitRarity = 3,
	Rarity = 3,
	MinWeight = 72,
	MaxWeight = 483
})
addFish("Terrorfish", {
	Tags = {
		"Teeth",
		"Fish",
		"Aggressive",
		"Carnivore"
	},
	RequiredBait = { "Carnivore Bait" },
	RequiredBaitRarity = 1,
	Rarity = 4,
	MinWeight = 28,
	MaxWeight = 190
})
addFish("Soggy Boot", {
	Tags = { "Trash", "Etc" },
	RequiredBait = nil,
	RequiredBaitRarity = 0,
	Rarity = 0,
	MinWeight = 12,
	MaxWeight = 12,
	BaseChance = probabilities.High,
	IsNotAFish = true
})
addFish("Rocket-Rocket", {
	Tags = { "PhysicalFruit", "Limited" },
	RequiredBait = nil,
	RequiredBaitRarity = 0,
	Rarity = 3,
	MinWeight = 12,
	MaxWeight = 12,
	BaseChance = probabilities.Lowest,
	IsNotAFish = true,
	CatchCooldown = 86400
})
addFish("Colossal Shrimp", {
	Tags = { "Fish", "Crustacean" },
	RequiredBait = nil,
	RequiredBaitRarity = 0,
	Rarity = 1,
	MinWeight = 6,
	MaxWeight = 43,
	BaseChance = probabilities.Low
})
addFish("Crab", {
	Tags = { "Fish", "Crustacean" },
	RequiredBait = nil,
	RequiredBaitRarity = 0,
	Rarity = 0,
	MinWeight = 5,
	MaxWeight = 34,
	BaseChance = probabilities.Low
})
addFish("Seahorse", {
	Tags = { "Fish", "Unique" },
	RequiredBait = nil,
	RequiredBaitRarity = 1,
	Rarity = 2,
	MinWeight = 7,
	MaxWeight = 48,
	BaseChance = probabilities.Lower
})
addFish("Dragon Koi", {
	Tags = { "Fish", "Special" },
	RequiredBait = nil,
	RequiredBaitRarity = 0,
	Rarity = 2,
	MinWeight = 5,
	MaxWeight = 38
})
addFish("KEYITEM_BOTTLE_RECIPE_MISC", {
	Tags = { "Recipe", "Limited", "KeyItem" },
	AwardKeyItem = "",
	RequiredBait = nil,
	RequiredBaitRarity = 0,
	Rarity = 2,
	MinWeight = 0,
	MaxWeight = 0,
	IsNotAFish = true
})
addFish("Hermit Crab", {
	Tags = { "Fish", "Crab" },
	RequiredBait = nil,
	RequiredBaitRarity = 0,
	Rarity = 1,
	MinWeight = 2,
	MaxWeight = 26
})
addFish("Turtle", {
	Tags = { "Fish", "Turtle" },
	RequiredBait = nil,
	RequiredBaitRarity = 0,
	Rarity = 1,
	MinWeight = 3,
	MaxWeight = 48
})
addFish("Lumo Whale", {
	Tags = { "Fish", "Whale", "Abyssal" },
	RequiredBait = { "Abyssal Bait" },
	RequiredBaitRarity = 1,
	Rarity = 2,
	MinWeight = 110,
	MaxWeight = 376,
	ScaleFactor = 8
})
addFish("Swamp Lurker", {
	Tags = { "Fish", "Abyssal" },
	RequiredBait = { "Abyssal Bait" },
	RequiredBaitRarity = 1,
	Rarity = 2,
	MinWeight = 76,
	MaxWeight = 210
})

for _, v2 in {
	"Pink",
	"Red",
	"Green",
	"Yellow",
	"Blue",
	"Purple"
} do
	addFish(`Starfish ({v2})`, {
		Tags = { "Fish", "Starfish" },
		RequiredBait = nil,
		RequiredBaitRarity = 0,
		Rarity = 0,
		MinWeight = 1,
		MaxWeight = 12,
		BaseChance = probabilities.Low
	})
end

addFish("Jellyfish", {
	Tags = { "Fish", "Abyssal", "Jellyfish" },
	RequiredBait = { "Abyssal Bait" },
	RequiredBaitRarity = 2,
	Rarity = 2,
	MinWeight = 2,
	MaxWeight = 30
})
addFish("Deepsea Octopus", {
	Tags = { "Fish", "Abyssal", "Octopus" },
	RequiredBait = { "Abyssal Bait" },
	RequiredBaitRarity = 1,
	Rarity = 2,
	MinWeight = 8,
	MaxWeight = 100
})
addFish("Deepsea Squid", {
	Tags = { "Fish", "Abyssal", "Squid" },
	RequiredBait = { "Abyssal Bait" },
	RequiredBaitRarity = 1,
	Rarity = 3,
	MinWeight = 8,
	MaxWeight = 100
})
addFish("Golden Carp", {
	Tags = { "Fish", "Event" },
	RequiredBait = nil,
	RequiredBaitRarity = 0,
	Rarity = 0,
	MinWeight = 1,
	MaxWeight = 1000,
	ScaleFactor = 12,
	FairWeightScaling = true
})
addFish("Vampire Squid", {
	Tags = { "Fish", "Abyssal", "Squid" },
	RequiredBait = { "Abyssal Bait" },
	RequiredBaitRarity = 1,
	Rarity = 3,
	MinWeight = 8,
	MaxWeight = 100,
	Hidden = true
})
addFish("Terrorbones", {
	Tags = {
		"Teeth",
		"Fish",
		"Aggressive",
		"Carnivore",
		"Halloween"
	},
	RequiredBait = { "Carnivore Bait" },
	RequiredBaitRarity = 1,
	Rarity = 4,
	MinWeight = 28,
	MaxWeight = 190,
	Hidden = true
})
addFish("Jester Clownfish", {
	Tags = {
		"Food",
		"Fish",
		"Kelp",
		"Halloween"
	},
	RequiredBait = nil,
	RequiredBaitRarity = 0,
	Rarity = 1,
	MinWeight = 5,
	MaxWeight = 37,
	Hidden = true
})
addFish("Jack-O-Fish", {
	Tags = {
		"Food",
		"Abyssal",
		"Fish",
		"Halloween"
	},
	RequiredBait = { "Abyssal Bait" },
	RequiredBaitRarity = 2,
	Rarity = 2,
	MinWeight = 6,
	MaxWeight = 41,
	Elusiveness = 3,
	Hidden = true
})
addFish("Zombie Bass", {
	Tags = {
		"Food",
		"Fish",
		"Kelp",
		"Halloween"
	},
	RequiredBait = nil,
	RequiredBaitRarity = 0,
	Rarity = 1,
	MinWeight = 5,
	MaxWeight = 35,
	Hidden = true
})
addFish("Reindeer Bullfish", {
	Tags = {
		"Fish",
		"Aggressive",
		"Carnivore",
		"Christmas"
	},
	RequiredBait = { "Carnivore Bait" },
	RequiredBaitRarity = 0,
	Rarity = 1,
	MinWeight = 4,
	MaxWeight = 33,
	Aggressiveness = 7
})
addFish("Snowman Marlin", {
	Tags = { "Fish", "Aggressive", "Christmas" },
	RequiredBait = nil,
	RequiredBaitRarity = 3,
	Rarity = 3,
	MinWeight = 72,
	MaxWeight = 483
})
addFish("Gingerbread Sturgeon", {
	Tags = { "Fish", "Christmas" },
	RequiredBait = nil,
	RequiredBaitRarity = 0,
	Rarity = 0,
	MinWeight = 5,
	MaxWeight = 37,
	Aggressiveness = 2,
	BaseChance = probabilities.Medium
})
addFish("Peppermint Fish", {
	Tags = {
		"Food",
		"Fish",
		"Sweet",
		"Christmas"
	},
	RequiredBait = nil,
	RequiredBaitRarity = 0,
	Rarity = 2,
	MinWeight = 6,
	MaxWeight = 47
})
local storageKeys = {}

for _, v2 in ItemConfig.Query.select({
	Index = {
		IdType = "Fish"
	}
}) do
	local itemId = v2.Index.ItemId

	if not fishIndex[itemId] then
		table.insert(storageKeys, ItemId.getDataFromId(itemId):unwrap().StorageKey)
	end
end

local _ = #storageKeys > 0
local nameMap = {}
local lookup = {}

for k, v4 in fishIndex do
	nameMap[v4.Name] = k
	lookup[v4.Name] = v4
end

return {
	FishIndex = fishIndex,
	NameMap = nameMap,
	Lookup = lookup
}