local ReplicatedStorage = game:GetService("ReplicatedStorage")
local lib = require(ReplicatedStorage.shared.modules.SimpleFetchQuests.lib)
require(ReplicatedStorage.shared.modules.Quests.Util)
return {
	AsheSkyCrystal = {
		DisplayName = "Ashe's Tropical Request",
		Icon = "rbxassetid://18409756966",
		IconColor = Color3.new(0, 0, 0),
		QuestType = "Side",
		Description = "Ashe wants to sample the delicacies of Skycrest.",
		NavigationTargets = {
			{
				Zone = "Skycrest",
				Objectives = { 1 }
			},
			{
				Zone = "Roslit",
				Tags = { "Ashe" },
				AllComplete = true
			}
		},
		DisplayList = {
			{ "Custom", 1, "Obtain any Albino-mutated Skycrest fish for Ashe" }
		},
		List = { lib.ObtainItem({
				Item = {
					"Celestial Pearl Danio",
					"Endler's Livebearer",
					"Ruby Neon Eviota",
					"Danionella Cerebrum",
					"Parotocinclus Halys",
					"Moenkhausia Pitanga",
					"Dwarf Pea Puffer",
					"Pink-Spotted Shrimpgoby",
					"Myloplus Sauron",
					"Populi Blind Catfish",
					"African Butterflyfish",
					"Blackcap Basslet",
					"Hawaiian Ventralis Anthias",
					"Vibranium Fairy Wrasse",
					"Aphrodite Anthias",
					"Rose-Veiled Fairy Wrasse",
					"Pineapple Pufferfish",
					"Banana Eel",
					"Smoothie Stingray",
					"Coconut Crabstle",
					"Hammock Halibut",
					"Hawaiian Shirt Shark",
					"Sunbed Stingray",
					"Watermelon Walrus",
					"Cabana Carp"
				},
				RequiredAmount = 1,
				RequiredAttributes = {
					Mutation = "Albino"
				},
				ForNpc = "Ashe"
			}) },
		Rewards = {
			{
				"ItemOrFish",
				"Campfire Sky Crystal",
				{},
				1
			}
		}
	}
}