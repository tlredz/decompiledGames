local module = require("../../SimpleFetchQuests/lib")
local Descendants = {}

local function descendantQuest(data)
	local list = {}
	local objectives = {}

	for k, catch in data.Catches do
		table.insert(list, module.CatchFish({
			Fish = catch.Fish,
			RequiredAmount = catch.Amount,
			RequiredAttributes = catch.Mutation and {
				Mutation = catch.Mutation
			} or nil,
			Rods = data.Rod,
			PerfectCatch = catch.Perfect
		}))
		table.insert(objectives, k)
	end

	Descendants[data.Id] = {
		DisplayName = `{data.Npc}: {data.Name}`,
		QuestType = "Major",
		Icon = "",
		IconColor = data.Color,
		CompletedDescription = data.CompletedDescription,
		AutoNavigate = true,
		AcceptIndicatorTag = data.Npc,
		NextTrack = "Vaelor2_BloodOfTheDeep",
		NavigationTargets = {
			{
				Zone = data.Zone,
				Tags = { data.ZoneTag },
				OnlyNearest = true,
				Objectives = objectives
			},
			{
				Zone = data.Zone,
				Tags = { data.Npc },
				AllComplete = true
			}
		},
		QuestSeries = data.Npc,
		SeriesIndex = 1,
		Prerequisites = {
			QuestActive = { "Vaelor2_BloodOfTheDeep" }
		},
		List = list,
		Rewards = {
			{
				"ItemOrFish",
				data.Reward,
				nil,
				1
			},
			{ "Xp", 25000 }
		}
	}
end

descendantQuest({
	Id = "Ignis1_CinderAndAsh",
	Npc = "Ignis",
	Color = Color3.fromRGB(255, 120, 60),
	Zone = "Volcanic Vents",
	ZoneTag = "VolcanicVentsFishing",
	Name = "Cinder and Ash",
	Rod = "Volcanic Rod",
	Catches = {
		{
			Fish = "Charred Coelacanth",
			Mutation = "Ashen Fortune",
			Amount = 2,
			Perfect = true
		},
		{
			Fish = "Obsidian-Plated Piranha",
			Mutation = "Ashen Fortune",
			Amount = 1
		}
	},
	CompletedDescription = "The scales are ready for study. Return to Ignis.",
	Reward = "Volcanic Gauntlets"
})
descendantQuest({
	Id = "Glacius1_FrozenVeins",
	Npc = "Glacius",
	Color = Color3.fromRGB(150, 215, 255),
	Zone = "Challenger's Deep",
	ZoneTag = "ChallengersDeepFishing",
	Name = "Frozen Veins",
	Rod = "Challenger's Rod",
	Catches = {
		{
			Fish = "Hoarfrost Halibut",
			Mutation = "Chilled",
			Amount = 3
		},
		{
			Fish = "Glacial Gulper",
			Mutation = "Chilled",
			Amount = 1,
			Perfect = true
		}
	},
	CompletedDescription = "The chilled catches are ready. Return to Glacius.",
	Reward = "Challenger's Gauntlets"
})
descendantQuest({
	Id = "Tenebris1_TwistedWrath",
	Npc = "Tenebris",
	Color = Color3.fromRGB(140, 60, 170),
	Zone = "Abyssal Zenith",
	ZoneTag = "AbyssalZenithFishing",
	Name = "Twisted Wrath",
	Rod = "Rod Of The Zenith",
	Catches = {
		{
			Fish = "Lumin-Lure Lanternfish",
			Mutation = "Wrath",
			Amount = 2
		},
		{
			Fish = "Void-Drifter Jelly",
			Mutation = "Wrath",
			Amount = 1,
			Perfect = true
		}
	},
	CompletedDescription = "The wrathful catches are ready. Return to Tenebris.",
	Reward = "Abyssal Gauntlets"
})
descendantQuest({
	Id = "Luminis1_ShiftingColors",
	Npc = "Luminis",
	Color = Color3.fromRGB(255, 235, 170),
	Zone = "Calm Zone",
	ZoneTag = "CalmZoneFishing",
	Name = "Shifting Colors",
	Rod = "Ethereal Prism Rod",
	Catches = {
		{
			Fish = "Geode Grouper",
			Mutation = "Prismize",
			Amount = 4
		},
		{
			Fish = "Pearl-Plated Pleco",
			Mutation = "Prismize",
			Amount = 2,
			Perfect = true
		}
	},
	CompletedDescription = "The prismized catches are ready. Return to Luminis.",
	Reward = "Calm Gauntlets"
})
descendantQuest({
	Id = "Resonus1_PhantomFrequencies",
	Npc = "Resonus",
	Color = Color3.fromRGB(120, 170, 160),
	Zone = "Veil of the Forsaken",
	ZoneTag = "ForsakenVeilFishing",
	Name = "Phantom Frequencies",
	Rod = "Leviathan's Fang Rod",
	Catches = {
		{
			Fish = "Gargoyle Goby",
			Amount = 5,
			Perfect = true
		},
		{
			Fish = "Wraith-Whisper Ray",
			Amount = 3,
			Perfect = true
		}
	},
	CompletedDescription = "The catches are ready. Return to Resonus.",
	Reward = "Veiled Gauntlets"
})
return Descendants