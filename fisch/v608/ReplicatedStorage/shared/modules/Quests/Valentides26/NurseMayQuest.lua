local module = require("../../EventConfig/Valentides26")
local module2 = require("../../SimpleFetchQuests/lib")
return {
	NurseMay1 = {
		DisplayName = "Nurse May's Remedy: Scattered Vials",
		Icon = "rbxassetid://70822794044383",
		IconColor = Color3.fromRGB(199, 120, 170),
		QuestType = "Major",
		AcceptIndicatorTag = "NurseMay",
		NavigationTargets = {
			{
				Tags = { "CerebraVial" },
				Objectives = { 1 },
				OnlyNearest = true
			},
			{
				Zone = "Sweetheart Shores",
				Tags = { "NurseMay" },
				AllComplete = true
			}
		},
		QuestSeries = "Nurse May's Remedy",
		SeriesIndex = 1,
		ExpiresAt = module.ExpiresAt,
		Description = "Nurse May has lost her medical vials across the sea! Help her find all 10 scattered vials and bring them back.",
		CompletedDescription = "You found all 10 vials! Return to Nurse May at Sweetheart Shores.",
		Prerequisites = {},
		List = {
			{
				"DataInstanceValue",
				"Cache.NurseMayVials",
				10,
				"Find the 10 Vials scattered across the sea"
			}
		},
		Rewards = {}
	},
	NurseMay2 = {
		DisplayName = "Nurse May's Remedy: Research Specimens",
		Icon = "rbxassetid://70822794044383",
		IconColor = Color3.fromRGB(199, 120, 170),
		QuestType = "Major",
		NavigationTargets = {
			{
				Zone = "Sweetheart Shores",
				Objectives = { 1, 2 }
			},
			{
				Zone = "Sweetheart Shores",
				Tags = { "NurseMay" },
				AllComplete = true
			}
		},
		QuestSeries = "Nurse May's Remedy",
		SeriesIndex = 2,
		ExpiresAt = module.ExpiresAt,
		Description = "Nurse May needs fish specimens for her research. Catch 2 Kissing Gourami, 2 Heart Cookies, and 1 Heart Sand Dollar at Sweetheart Shores.",
		CompletedDescription = "You caught all the specimens! Return to Nurse May.",
		Prerequisites = {
			QuestComplete = { "NurseMay1" }
		},
		List = { module2.CatchFishAny({
				RequiredAmount = 2,
				Fish = "Kissing Gourami",
				PlayerZones = "Sweetheart Shores"
			}), module2.CatchFishAny({
				RequiredAmount = 2,
				Fish = "Heart Cookie",
				PlayerZones = "Sweetheart Shores"
			}), module2.CatchFishAny({
				RequiredAmount = 1,
				Fish = "Heart Sand Dollar",
				PlayerZones = "Sweetheart Shores"
			}) },
		Rewards = {
			{ "LocalCurrency", "Chocolates", 250 }
		}
	},
	NurseMay3 = {
		DisplayName = "Nurse May's Remedy: The Cerebra",
		Icon = "rbxassetid://70822794044383",
		IconColor = Color3.fromRGB(199, 120, 170),
		QuestType = "Major",
		AcceptIndicatorTag = "NurseMay",
		NavigationTargets = {
			{
				Zone = "Sweetheart Shores",
				Tags = { "NurseMay" }
			}
		},
		QuestSeries = "Nurse May's Remedy",
		SeriesIndex = 3,
		ExpiresAt = module.ExpiresAt,
		Description = "Nurse May has finished her research. Return to her to receive your reward.",
		CompletedDescription = "",
		Prerequisites = {
			QuestComplete = { "NurseMay2" }
		},
		List = {
			{
				"DataInstanceValue",
				"Cache.NurseMayCerebra",
				true,
				"Speak to Nurse May to receive your reward"
			}
		},
		Rewards = {
			{ "Rod", "Cerebra" },
			{ "LocalCurrency", "Chocolates", 750 }
		}
	}
}