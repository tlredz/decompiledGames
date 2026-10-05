local ReplicatedStorage = game:GetService("ReplicatedStorage")
local color = Color3.fromRGB(77, 128, 142)
local lib = require(ReplicatedStorage.shared.modules.SimpleFetchQuests.lib)
require(ReplicatedStorage.shared.modules.Quests.Util)
local KeeperOfTheSky = {
	KeeperOfTheSky_Main1 = {
		DisplayName = "Keeper of the Sky: Echoes of the Idols",
		Description = "",
		AutoNavigate = true,
		List = {
			{ "Custom", true, "Seek an Ancient Idol and satisfy its first trial" },
			lib.CatchFishAny({
				RequiredAmount = 10,
				PlayerZones = { "Skycrest" }
			})
		},
		QuestSeries = "Keeper of the Sky",
		SeriesIndex = 1,
		Rewards = {
			{ "IdolFavor", 100 }
		}
	},
	KeeperOfTheSky_Main2 = {
		DisplayName = "Keeper of the Sky: The Elder's Market & The Master's Test",
		Description = "",
		AutoNavigate = true,
		List = {
			{ "Custom", 5, "Reach Idol Favor Level 5" },
			{ "Custom", true, "Purchase any item from Elder Kaito's Shop" },
			{ "Custom", true, "Accept any task from Master Hiroto" }
		},
		QuestSeries = "Keeper of the Sky",
		SeriesIndex = 2,
		Prerequisites = {
			QuestComplete = { "KeeperOfTheSky_Main1" }
		},
		Rewards = {
			{
				"ItemOrFish",
				"Crested Relic",
				{
					Mutation = "Unsellable"
				},
				1
			},
			{ "IdolFavor", 250 }
		}
	},
	KeeperOfTheSky_Main3 = {
		DisplayName = "Keeper of the Sky: Companion of the Squall",
		Description = "",
		NavigationTargets = {
			{
				Zone = "Abaia's Chamber",
				Tags = { "FireOfSpirits" },
				Objectives = { 1 },
				ObjectiveValues = { 0 }
			}
		},
		AutoNavigate = true,
		List = {
			{
				"Custom",
				2,
				{
					"Wait for or summon a Tropical Squall",
					"Locate a roaming Idol Taiga near an Ancient Idol, and feed it Fireflies until tamed"
				}
			}
		},
		QuestSeries = "Keeper of the Sky",
		SeriesIndex = 3,
		Prerequisites = {
			QuestComplete = { "KeeperOfTheSky_Main2" }
		},
		Rewards = {
			{
				"ItemOrFish",
				"Crested Relic",
				{
					Mutation = "Unsellable"
				},
				1
			},
			{ "IdolFavor", 750 }
		}
	},
	KeeperOfTheSky_Main4 = {
		DisplayName = "Keeper of the Sky: Crystal Reclamation",
		Description = "",
		NavigationTargets = {
			{
				Zone = "Skycrest",
				Tags = { "KeeperOfTheSky" },
				Objectives = { 2 }
			},
			{
				Zone = "Skycrest",
				Tags = { "SkycrestGate" },
				Objectives = { 2 }
			}
		},
		AutoNavigate = true,
		List = {
			{ "Custom", 50, "Reach Idol Favor Level 50" },
			{ "Custom", 10, "Obtain and place all Sky Crystals around the gate" }
		},
		QuestSeries = "Keeper of the Sky",
		SeriesIndex = 4,
		Prerequisites = {
			QuestComplete = { "KeeperOfTheSky_Main3" }
		},
		Rewards = {
			{ "IdolFavor", 1000 }
		}
	},
	KeeperOfTheSky_Main5 = {
		DisplayName = "Keeper of the Sky: The Ritual of Flame",
		Description = "",
		NavigationTargets = {
			{
				Zone = "Abaia's Chamber",
				Tags = { "FireOfSpirits" },
				Objectives = { 1 }
			}
		},
		AutoNavigate = true,
		List = {
			{ "Custom", true, "Perform a fish sacrifice at the Fire of Spirits to grow the flame" }
		},
		QuestSeries = "Keeper of the Sky",
		SeriesIndex = 5,
		Prerequisites = {
			QuestComplete = { "KeeperOfTheSky_Main4" }
		},
		Rewards = {
			{ "DisplayOnly", "Access to <b>Abaia Hunt Summoning</b>" },
			{
				"ItemOrFish",
				"Empyrean Relic",
				{
					Mutation = "Unsellable"
				},
				1
			},
			{ "IdolFavor", 2000 }
		}
	},
	KeeperOfTheSky_Main6 = {
		DisplayName = "Keeper of the Sky: The Abaia Awakening",
		Description = "",
		NavigationTargets = {
			{
				Zone = "Abaia's Chamber",
				Tags = { "FireOfSpirits" },
				Objectives = { 1 },
				ObjectiveValues = { 0, 1 }
			}
		},
		AutoNavigate = true,
		List = {
			{
				"Custom",
				7,
				{
					"Wait for or summon a Tropical or Raging Squall",
					"Awaken an Abaia Hunt via Sacrifices",
					"Track Abaia down and remove its protection barriers (0/4)",
					"Track Abaia down and remove its protection barriers (1/4)",
					"Track Abaia down and remove its protection barriers (2/4)",
					"Track Abaia down and remove its protection barriers (3/4)",
					"Return to the main chamber and catch the Abaia before it retreats!"
				}
			}
		},
		QuestSeries = "Keeper of the Sky",
		SeriesIndex = 6,
		Prerequisites = {
			QuestComplete = { "KeeperOfTheSky_Main5" }
		},
		Rewards = {
			{
				"ItemOrFish",
				"Line of the Skies",
				{},
				1
			},
			{ "Title", "Sky Keeper" }
		}
	},
	KeeperOfTheSky_UnboundAmulet = {
		DisplayName = "Spark of the Skies",
		QuestType = "Side",
		Description = "",
		List = {
			{ "Custom", 1, "Obtain a Firefly" },
			{ "Custom", 1, "Obtain a Loopy Five Firefly" },
			{ "Custom", 1, "Obtain a Blue Ghost Firefly" },
			{ "Custom", 1, "Obtain a Gombak Bent-Winged Firefly" }
		},
		Prerequisites = {
			QuestComplete = { "KeeperOfTheSky_Main1" }
		},
		Rewards = {
			{ "DisplayOnly", "<b>Charms</b> now work outside of Skycrest" }
		}
	}
}

for _, v in KeeperOfTheSky do
	v.AcceptIndicatorTag = "KeeperOfTheSky"
	v.Icon = "rbxassetid://0"
	v.IconColor = color

	if not v.QuestType then
		v.QuestType = "Major"
	end

	if not v.NavigationTargets then
		v.NavigationTargets = {}
	end

	table.insert(v.NavigationTargets, {
		Zone = "Skycrest",
		Tags = { "KeeperOfTheSky" },
		AllComplete = true
	})
end

return KeeperOfTheSky