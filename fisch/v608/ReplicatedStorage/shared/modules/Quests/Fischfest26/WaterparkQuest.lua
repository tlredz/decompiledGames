local module = require("../../SimpleFetchQuests/lib")
local color = Color3.fromRGB(64, 191, 255)
local dateTime = DateTime.fromUniversalTime(2026, 9, 12, 16)
local count = 0

local function seriesIndex()
	count += 1
	return count
end

count += 1
local waterpark_Unclog = {
	DisplayName = "Waterpark: Clogged Pipes",
	QuestType = "Major",
	Icon = "rbxassetid://0",
	IconColor = color,
	ExpiresAt = dateTime,
	CompletedDescription = "The pipes are clear! Head back to Waterpark Wade.",
	AutoNavigate = true,
	AcceptIndicatorTag = "WaterparkWade",
	NavigationTargets = {
		{
			Zone = "Fischfest",
			Tags = { "WaterparkSlidesNav" },
			Objectives = { 1 }
		},
		{
			Zone = "Fischfest",
			Tags = { "WaterparkPoolNav" },
			Objectives = { 2 }
		},
		{
			Zone = "Fischfest",
			Tags = { "WaterparkRiverNav" },
			Objectives = { 3 }
		},
		{
			Zone = "Fischfest",
			Tags = { "WaterparkWade" },
			AllComplete = true
		}
	},
	QuestSeries = "Waterpark",
	SeriesIndex = count,
	List = { module.CatchFishAny({
			RequiredAmount = 5,
			FishingZones = { "Waterpark Slides" }
		}), module.CatchFishAny({
			RequiredAmount = 5,
			FishingZones = { "Waterpark Pool" }
		}), module.CatchFishAny({
			RequiredAmount = 5,
			FishingZones = { "Waterpark Lazy River" }
		}) },
	Rewards = {
		{ "Skin", "Rubber Ducky Floatie" },
		{ "LocalCurrency", "Sunshells", 500 },
		{ "Xp", 5000 }
	}
}
count += 1
local WaterparkQuest = {
	Waterpark_Unclog = waterpark_Unclog,
	Waterpark_TestRun = {
		DisplayName = "Waterpark: Test Run",
		QuestType = "Major",
		Icon = "rbxassetid://0",
		IconColor = color,
		ExpiresAt = dateTime,
		CompletedDescription = "Everything's working! Let Waterpark Wade know.",
		AutoNavigate = true,
		AcceptIndicatorTag = "WaterparkWade",
		NavigationTargets = {
			{
				Zone = "Fischfest",
				Tags = { "WaterparkTestSlides" },
				Objectives = { 1 }
			},
			{
				Zone = "Fischfest",
				Tags = { "WaterparkTestPool" },
				Objectives = { 2 }
			},
			{
				Zone = "Fischfest",
				Tags = { "WaterparkTestRiver" },
				Objectives = { 3 }
			},
			{
				Zone = "Fischfest",
				Tags = { "WaterparkWade" },
				AllComplete = true
			}
		},
		QuestSeries = "Waterpark",
		SeriesIndex = count,
		List = {
			{ "Custom", true, "Test out the water slides" },
			{ "Custom", true, "Test out the pool" },
			{ "Custom", true, "Test out the lazy river" }
		},
		Rewards = {
			{ "Title", "Waterpark Engineer" },
			{ "Boat", "Sunslasher Popsicle Floatie" },
			{ "LocalCurrency", "Sunshells", 1500 },
			{ "Xp", 10000 }
		}
	}
}

for k, v3 in {
	{
		Id = "Waterpark_MiloFloatie",
		Npc = "Milo",
		Tag = "WaterparkMilo",
		Fish = "Pufferfish Floatie",
		Zone = "Waterpark Pool"
	},
	{
		Id = "Waterpark_RyderFloatie",
		Npc = "Ryder",
		Tag = "WaterparkRyder",
		Fish = "Crab Floatie",
		Zone = "Waterpark Slides"
	},
	{
		Id = "Waterpark_DrewFloatie",
		Npc = "Drew",
		Tag = "WaterparkDrew",
		Fish = "Dumbo Octopus Floatie",
		Zone = "Waterpark Lazy River"
	}
} do
	WaterparkQuest[v3.Id] = {
		DisplayName = `Waterpark Floaties: {v3.Npc}'s Floatie`,
		QuestType = "Side",
		Icon = "rbxassetid://0",
		IconColor = color,
		ExpiresAt = dateTime,
		CompletedDescription = `You found {v3.Npc}'s {v3.Fish}! Bring it back to them.`,
		AutoNavigate = true,
		AcceptIndicatorTag = v3.Tag,
		NavigationTargets = {
			{
				Zone = "Fischfest",
				Tags = { v3.Tag },
				AllComplete = true
			}
		},
		QuestSeries = "Waterpark Floaties",
		SeriesIndex = count + k,
		Prerequisites = {
			QuestComplete = { "Waterpark_TestRun" }
		},
		List = { module.CatchFishAny({
				Fish = v3.Fish,
				RequiredAmount = 1,
				FishingZones = { v3.Zone },
				AndReturn = true
			}) },
		Rewards = {
			{ "Boat", v3.Fish },
			{ "LocalCurrency", "Sunshells", 750 },
			{ "Xp", 4000 }
		}
	}
end

local v3 = {}

for k, v4 in WaterparkQuest do
	v3[v4.SeriesIndex] = k
end

for k, v4 in v3 do
	local v5 = v3[k - 1]

	if not v5 then
		continue
	end

	local v6 = WaterparkQuest[v4]

	if not v6.Prerequisites then
		v6.Prerequisites = {
			QuestComplete = { v5 }
		}
	end
end

return WaterparkQuest