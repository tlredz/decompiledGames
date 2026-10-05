local ReplicatedStorage = game:GetService("ReplicatedStorage")
local color = Color3.fromRGB(193, 233, 255)
local lib = require(ReplicatedStorage.shared.modules.SimpleFetchQuests.lib)
return {
	AstralBrayden1 = {
		DisplayName = "Anomaly Investigation: Brayden's Star Projector",
		QuestType = "Major",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		Description = "Brayden needs help repairing his Star Projector.",
		NavigationTargets = {
			{
				Zone = "Boreal Pines",
				Tags = { "AstralBrayden" },
				AllComplete = true
			}
		},
		List = {
			{ "Custom", 6, "Gather the broken stars" }
		},
		QuestSeries = "AstralBrayden",
		SeriesIndex = 1,
		AcceptIndicatorTag = "AstralBrayden",
		Prerequisites = {},
		DisplayRewardsFrom = "AstralBrayden2",
		Rewards = {}
	},
	AstralBrayden2 = {
		DisplayName = "Anomaly Investigation: Brayden's Star Projector",
		QuestType = "Major",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		Description = "Brayden needs help repairing his Star Projector.",
		NavigationTargets = {
			{
				Zone = "Boreal Pines",
				Tags = { "AstralBrayden" },
				AllComplete = true
			}
		},
		List = { lib.CatchFishAny({
				Fish = "Resin",
				AndReturn = true
			}), lib.ObtainItem({
				Item = "Glass Diamond",
				RequiredAttributes = {
					Mutation = "Aurora"
				},
				ForNpc = "Brayden"
			}) },
		QuestSeries = "AstralBrayden",
		SeriesIndex = 2,
		AcceptIndicatorTag = "AstralBrayden",
		Prerequisites = {
			QuestComplete = { "AstralBrayden1" }
		},
		Rewards = {
			{
				"ItemOrFish",
				"Stellar Lens",
				{},
				1
			},
			{ "DisplayOnly", "???" }
		}
	},
	AstralMatthew1 = {
		DisplayName = "Anomaly Investigation: SPACE CANDY!!!!",
		QuestType = "Major",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		Description = "",
		NavigationTargets = {
			{
				Zone = "Northern Expedition",
				Tags = { "AstralMatthew" },
				AllComplete = true
			}
		},
		List = {
			{ "Custom", 1, "Obtain 1 Cosmic Relic from Fallen Stars" },
			lib.ObtainItem({
				Item = "Moonstone",
				RequiredAmount = 1,
				ForNpc = "Meteor Maniac Matthew"
			}),
			lib.ObtainItem({
				Fish = "Frozen Walnut",
				RequiredAmount = 1,
				RequiredAttributes = {
					Mutation = { "Solarblaze", "Nova" }
				},
				ForNpc = "Meteor Maniac Matthew"
			})
		},
		QuestSeries = "AstralMatthew",
		SeriesIndex = 1,
		AcceptIndicatorTag = "AstralMatthew",
		Prerequisites = {},
		Rewards = {
			{
				"ItemOrFish",
				"Stardust Candy",
				{},
				1
			}
		}
	},
	AstralMatthew2 = {
		DisplayName = "Anomaly Investigation: METEORS GALORE!!!!",
		QuestType = "Major",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		Description = "",
		AutoNavigate = true,
		NavigationTargets = {
			{
				Zone = "Northern Expedition",
				Tags = { "NorthMeteor" },
				Objectives = { 1 }
			},
			{
				Zone = "Northern Expedition",
				Tags = { "AstralMatthew" },
				AllComplete = true
			}
		},
		List = {
			{ "Custom", 10, "Clean up the fallen meteors around Northern Expedition with a Pickaxe" },
			lib.CatchFishAny({
				Fish = "Quartz Glass",
				RequiredAmount = 1,
				AndReturn = true
			}),
			lib.ObtainItem({
				Item = "Stalactite",
				RequiredAmount = 5,
				RequiredAttributes = {
					Mutation = "Solarblaze"
				},
				ForNpc = "Meteor Maniac Matthew"
			}),
			lib.ObtainItem({
				Item = "Ruby",
				RequiredAmount = 1,
				ForNpc = "Meteor Maniac Matthew"
			}),
			lib.ObtainItem({
				Item = "Amethyst",
				RequiredAmount = 1,
				ForNpc = "Meteor Maniac Matthew"
			}),
			lib.ObtainItem({
				Item = "Opal",
				RequiredAmount = 1,
				ForNpc = "Meteor Maniac Matthew"
			}),
			lib.ObtainItem({
				Item = "Lapis Lazuli",
				RequiredAmount = 1,
				ForNpc = "Meteor Maniac Matthew"
			}),
			lib.ObtainItem({
				Item = "Moonstone",
				RequiredAmount = 1,
				ForNpc = "Meteor Maniac Matthew"
			})
		},
		QuestSeries = "AstralMatthew",
		SeriesIndex = 2,
		AcceptIndicatorTag = "AstralMatthew",
		Prerequisites = {
			QuestComplete = { "AstralMatthew1" }
		},
		Rewards = {
			{ "Rod", "Meteoric Rod" }
		}
	}
}