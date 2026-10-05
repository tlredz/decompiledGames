local module = require("../../SimpleFetchQuests/lib")
local color = Color3.fromRGB(220, 160, 60)
local dateTime = DateTime.fromUnixTimestamp(1784563200)
local RivetRodQuest = {
	RivetRod1 = {
		DisplayName = "Rivet: Research Materials",
		Icon = "rbxassetid://77215890862281",
		IconColor = color,
		QuestType = "Major",
		AcceptIndicatorTag = "Rivet",
		NavigationTargets = {
			{
				Tags = { "Rivet" },
				AllComplete = true
			}
		},
		Description = "Rivet needs scrap for his research. Bring him 1 Rusty Bolt, 1 Broken Gear, and 1 Scrap Metal.",
		CompletedDescription = "Return to Rivet to deliver the materials.",
		ExpiresAt = dateTime,
		List = { module.ObtainItem({
				Item = "Rusty Bolt",
				RequiredAmount = 1,
				ForNpc = "Rivet"
			}), module.ObtainItem({
				Item = "Broken Gear",
				RequiredAmount = 1,
				ForNpc = "Rivet"
			}), module.ObtainItem({
				Item = "Scrap Metal",
				RequiredAmount = 1,
				ForNpc = "Rivet"
			}) },
		Rewards = {
			{ "Currency", "Coins", 7500 }
		}
	},
	RivetRod2 = {
		DisplayName = "Rivet: Repairing the Rod",
		Icon = "rbxassetid://77215890862281",
		IconColor = color,
		QuestType = "Major",
		AcceptIndicatorTag = "Rivet",
		NavigationTargets = {
			{
				Tags = { "Rivet" },
				AllComplete = true
			}
		},
		Description = "Rivet is repairing his Steampunk Rod. Bring him 3 Purified Rusty Bolts, 3 Midas Broken Gears, and 3 Crystallized Scrap Metal.",
		CompletedDescription = "Return to Rivet to deliver the rare materials.",
		ExpiresAt = dateTime,
		Prerequisites = {
			QuestComplete = { "RivetRod1" }
		},
		List = { module.ObtainItem({
				Item = "Rusty Bolt",
				RequiredAmount = 3,
				RequiredAttributes = {
					Mutation = "Purified"
				},
				ForNpc = "Rivet"
			}), module.ObtainItem({
				Item = "Broken Gear",
				RequiredAmount = 3,
				RequiredAttributes = {
					Mutation = "Midas"
				},
				ForNpc = "Rivet"
			}), module.ObtainItem({
				Item = "Scrap Metal",
				RequiredAmount = 3,
				RequiredAttributes = {
					Mutation = "Crystalized"
				},
				ForNpc = "Rivet"
			}) },
		Rewards = {
			{ "Boat", "Rivet's Motorcycle" }
		}
	},
	RivetRod3 = {
		DisplayName = "Rivet: Powering the Rod",
		Icon = "rbxassetid://77215890862281",
		IconColor = color,
		QuestType = "Major",
		AcceptIndicatorTag = "Rivet",
		NavigationTargets = {
			{
				Tags = { "Rivet" },
				AllComplete = true
			}
		},
		Description = "Catch an Electric Kerauno Wyrm to power up the Steampunk Rod, and travel 75,000 studs with Rivet's Motorcycle.",
		CompletedDescription = "Return to Rivet to claim the Steampunk Rod.",
		ExpiresAt = dateTime,
		Prerequisites = {
			QuestComplete = { "RivetRod2" }
		},
		List = {
			module.CatchFishAny({
				Fish = "Kerauno Wyrm",
				RequiredAmount = 1,
				RequiredAttributes = {
					Mutation = "Electric"
				},
				AndReturn = true
			}),
			{
				"DataInstanceValue",
				"Cache.RivetMotorcycleDistance",
				75000,
				"Travel 75,000 studs with Rivet's Motorcycle"
			}
		},
		Rewards = {
			{ "Rod", "Steampunk Rod" }
		}
	}
}

for _, v in RivetRodQuest do
	v.WishLocked = "SteampunkRod"
	v.AcceptIndicatorTag = "WishEcho"
	v.NavigationTargets = {
		{
			Zone = "Skycrest",
			Tags = { "WishEcho" }
		}
	}
end

return RivetRodQuest