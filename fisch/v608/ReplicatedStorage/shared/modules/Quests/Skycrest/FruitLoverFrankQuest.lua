local module = require("../../SimpleFetchQuests/lib")
local color = Color3.fromRGB(255, 197, 97)
local dateTime = DateTime.fromUniversalTime(2026, 9, 12, 16)
local v = {
	"Pineapple Pufferfish",
	"Banana Eel",
	"Smoothie Stingray",
	"Coconut Crabstle",
	"Hammock Halibut",
	"Hawaiian Shirt Shark",
	"Sunbed Stingray",
	"Watermelon Walrus",
	"Cabana Carp"
}
local count = 0

local function seriesIndex()
	count += 1
	return count
end

local function limitedFishObjectives()
	local result = {}

	for _, fish in v do
		table.insert(result, module.CatchFishAny({
			Fish = fish,
			RequiredAmount = 1,
			AndReturn = true
		}))
	end

	return result
end

count += 1
local frank1_FruitBasket = {
	DisplayName = "Fruit Lover Frank: The Empty Basket",
	QuestType = "Major",
	Icon = "rbxassetid://0",
	IconColor = color,
	CompletedDescription = "Frank's basket is full. Go show him.",
	ExpiresAt = dateTime,
	AutoNavigate = true,
	AcceptIndicatorTag = "FruitLoverFrank",
	NavigationTargets = {
		{
			Zone = "Skycrest",
			Tags = { "FruitLoverFrank" },
			AllComplete = true
		}
	},
	QuestSeries = "Fruit Lover Frank",
	SeriesIndex = count,
	List = {
		{ "Custom", 25, "Collect every tropical fruit around Skycrest" }
	},
	Rewards = {
		{ "IdolFavor", 500 }
	}
}
count += 1
local FruitLoverFrankQuest = {
	Frank1_FruitBasket = frank1_FruitBasket,
	Frank2_LimitedCatches = {
		DisplayName = "Fruit Lover Frank: The Ocean's Pulp",
		QuestType = "Major",
		Icon = "rbxassetid://0",
		IconColor = color,
		CompletedDescription = "You caught one of everything. Bring them to Frank.",
		ExpiresAt = dateTime,
		AutoNavigate = true,
		AcceptIndicatorTag = "FruitLoverFrank",
		NavigationTargets = {
			{
				Zone = "Skycrest",
				Tags = { "FruitLoverFrank" },
				AllComplete = true
			}
		},
		QuestSeries = "Fruit Lover Frank",
		SeriesIndex = count,
		List = limitedFishObjectives(),
		Rewards = {
			{ "IdolFavor", 1000 }
		}
	}
}
count += 1
FruitLoverFrankQuest.Frank3_Ritual = {
	DisplayName = "Fruit Lover Frank: The Ritual of Sweetness",
	QuestType = "Major",
	Icon = "rbxassetid://0",
	IconColor = color,
	CompletedDescription = "The ritual is done. Tell Frank.",
	ExpiresAt = dateTime,
	AutoNavigate = true,
	AcceptIndicatorTag = "FruitLoverFrank",
	NavigationTargets = {
		{
			Zone = "Skycrest",
			Tags = { "FireOfSpirits" },
			Objectives = { 1 }
		},
		{
			Zone = "Skycrest",
			Tags = { "FruitLoverFrank" },
			AllComplete = true
		}
	},
	QuestSeries = "Fruit Lover Frank",
	SeriesIndex = count,
	List = {
		{ "Custom", true, "Offer all Limited Skycrest fish at the Fire of Spirits during a Tropical Sun" }
	},
	Rewards = {
		{ "IdolFavor", 2500 }
	}
}
count += 1
FruitLoverFrankQuest.Frank4_FruityAbaia = {
	DisplayName = "Fruit Lover Frank: The ULTIMATE Blend",
	QuestType = "Major",
	Icon = "rbxassetid://0",
	IconColor = color,
	CompletedDescription = "You hooked the king of fruits. Take it to Frank.",
	ExpiresAt = dateTime,
	AutoNavigate = true,
	AcceptIndicatorTag = "FruitLoverFrank",
	NavigationTargets = {
		{
			Zone = "Skycrest",
			Tags = { "FruitLoverFrank" },
			AllComplete = true
		}
	},
	QuestSeries = "Fruit Lover Frank",
	SeriesIndex = count,
	List = { module.CatchFishAny({
			Fish = "Fruity Abaia",
			RequiredAmount = 1,
			AndReturn = true
		}) },
	Rewards = {
		{ "Rod", "Fruitline" },
		{ "IdolFavor", 5000 }
	}
}
local v6 = {}

for k, v7 in FruitLoverFrankQuest do
	v6[v7.SeriesIndex] = k
end

for k, v7 in v6 do
	local v8 = v6[k - 1]

	if not v8 then
		continue
	end

	local v9 = FruitLoverFrankQuest[v7]

	if not v9.Prerequisites then
		v9.Prerequisites = {
			QuestComplete = { v8 }
		}
	end
end

return FruitLoverFrankQuest