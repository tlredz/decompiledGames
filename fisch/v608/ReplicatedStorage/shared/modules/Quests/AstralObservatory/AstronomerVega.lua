local ReplicatedStorage = game:GetService("ReplicatedStorage")
local color = Color3.fromRGB(196, 128, 255)
local lib = require(ReplicatedStorage.shared.modules.SimpleFetchQuests.lib)
return {
	AstronomerVega1 = {
		DisplayName = "A Battery Dilemma",
		QuestType = "Major",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		Description = "Vega has almost finished his telescope for the observatory, but is in need of batteries to power it...",
		AutoNavigate = true,
		NavigationTargets = {
			{
				Zone = "The Laboratory",
				Tags = { "AstronomerVega" },
				AllComplete = true
			}
		},
		List = { lib.ObtainItem({
				Item = "Battery Casing",
				RequiredAmount = 2,
				ForNpc = "Astronomer Vega"
			}) },
		QuestSeries = "Astronomer Vega",
		SeriesIndex = 1,
		AcceptIndicatorTag = "AstronomerVega",
		Prerequisites = {},
		Rewards = {}
	},
	AstronomerVega2 = {
		DisplayName = "Activating the Telescope",
		QuestType = "Major",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		Description = "Vega has almost finished his telescope for the observatory, but is in need of some special lenses...",
		AutoNavigate = true,
		NavigationTargets = {
			{
				Zone = "Abyssal Zenith",
				Tags = { "AstralCorvus" },
				Objectives = { 1 }
			},
			{
				Zone = "Boreal Pines",
				Tags = { "AstralBrayden" },
				Objectives = { 1 }
			},
			{
				Zone = "Northern Expedition",
				Tags = { "AstralMatthew" },
				Objectives = { 1 }
			},
			{
				Zone = "The Laboratory",
				Tags = { "AstronomerVega" },
				AllComplete = true
			}
		},
		List = {
			{ "Custom", 1, "Complete any Anomaly Investigation quest" }
		},
		QuestSeries = "Astronomer Vega",
		SeriesIndex = 2,
		AcceptIndicatorTag = "AstronomerVega",
		Prerequisites = {
			QuestComplete = { "AstronomerVega1" }
		},
		Rewards = {
			{ "DisplayOnly", "Unlocks the <b>Observatory Telescope</b>" }
		}
	}
}