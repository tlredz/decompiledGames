local color = Color3.fromRGB(120, 96, 200)
local count = 0

local function seriesIndex()
	count += 1
	return count
end

count += 1
local vaelor1_ChartTheVeil = {
	DisplayName = "Vaelor: Chart the Veil",
	QuestType = "Major",
	Icon = "",
	IconColor = color,
	CompletedDescription = "Every layer is charted. Return to Vaelor in Roslit Bay.",
	AutoNavigate = true,
	AcceptIndicatorTag = "Vaelor",
	NavigationTargets = {
		{
			Tags = {
				"VolcanicVentsFishing",
				"ChallengersDeepFishing",
				"AbyssalZenithFishing",
				"CalmZoneFishing",
				"ForsakenVeilFishing"
			},
			Objectives = { 1 }
		},
		{
			Zone = "Roslit",
			Tags = { "Vaelor" },
			AllComplete = true
		}
	},
	QuestSeries = "Vaelor",
	SeriesIndex = count,
	List = {
		{ "Custom", 5, "Discover all of Mariana's Veil" }
	},
	Rewards = {}
}
count += 1
local Vaelor = {
	Vaelor1_ChartTheVeil = vaelor1_ChartTheVeil,
	Vaelor2_BloodOfTheDeep = {
		DisplayName = "Vaelor: Worthy of the Abyss",
		QuestType = "Major",
		Icon = "",
		IconColor = color,
		CompletedDescription = "Every descendant is satisfied. Return to Vaelor in Roslit Bay.",
		AutoNavigate = true,
		AcceptIndicatorTag = "Vaelor",
		NavigationTargets = {
			{
				Zone = "Volcanic Vents",
				Tags = { "Ignis" },
				Objectives = { 1 }
			},
			{
				Zone = "Challenger's Deep",
				Tags = { "Glacius" },
				Objectives = { 2 }
			},
			{
				Zone = "Abyssal Zenith",
				Tags = { "Tenebris" },
				Objectives = { 3 }
			},
			{
				Zone = "Calm Zone",
				Tags = { "Luminis" },
				Objectives = { 4 }
			},
			{
				Zone = "Veil of the Forsaken",
				Tags = { "Resonus" },
				Objectives = { 5 }
			},
			{
				Zone = "Roslit",
				Tags = { "Vaelor" },
				AllComplete = true
			}
		},
		QuestSeries = "Vaelor",
		SeriesIndex = count,
		List = {
			{ "Custom", true, "Satisfy Ignis in the Volcanic Vents" },
			{ "Custom", true, "Satisfy Glacius in Challenger's Deep" },
			{ "Custom", true, "Satisfy Tenebris in the Abyssal Zenith" },
			{ "Custom", true, "Satisfy Luminis in the Calm Zone" },
			{ "Custom", true, "Satisfy Resonus in the Veil of the Forsaken" }
		},
		Rewards = {}
	}
}
count += 1
Vaelor.Vaelor3_IntoTheVoid = {
	DisplayName = "Vaelor: Into the Void",
	QuestType = "Major",
	Icon = "",
	IconColor = color,
	CompletedDescription = "You found the crevice below.",
	AutoComplete = true,
	AutoAdvance = true,
	AutoNavigate = true,
	AcceptIndicatorTag = "Vaelor",
	NavigationTargets = {
		{
			Zone = "Veil of the Forsaken",
			Tags = { "ForsakenVeilFishing" },
			OnlyNearest = true,
			Objectives = { 1 },
			ObjectiveValues = { 0 }
		},
		{
			Zone = "Veil of the Forsaken",
			Tags = { "ObsidianVoid" },
			OnlyNearest = true,
			Objectives = { 1 },
			ObjectiveValues = { 1 }
		}
	},
	QuestSeries = "Vaelor",
	SeriesIndex = count,
	List = {
		{
			"Custom",
			2,
			{ "<b>Perfect</b> Catch a Scylla", "Jump blindly into the void" }
		}
	},
	Rewards = {}
}
count += 1
Vaelor.Vaelor4_ObsidianThreshold = {
	DisplayName = "Vaelor: The Obsidian Threshold",
	QuestType = "Major",
	Icon = "",
	IconColor = color,
	CompletedDescription = "The gate has opened.",
	AutoComplete = true,
	AcceptIndicatorTag = "Vaelor",
	QuestSeries = "Vaelor",
	SeriesIndex = count,
	List = {
		{
			"Custom",
			2,
			{ "Solve your unique riddle", "Present your catch at the gate" }
		}
	},
	Rewards = {
		{
			"ItemOrFish",
			"Mariana's Gauntlets",
			nil,
			1
		},
		{ "Xp", 50000 }
	}
}
local v5 = {}

for k, v6 in Vaelor do
	v5[v6.SeriesIndex] = k
end

for k, v6 in v5 do
	local v7 = v5[k - 1]

	if not v7 then
		continue
	end

	local v8 = Vaelor[v6]

	if not v8.Prerequisites then
		v8.Prerequisites = {
			QuestComplete = { v7 }
		}
	end
end

return Vaelor