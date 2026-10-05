local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Ghastly Tide",
	DisplayName = "Ghastly Tide",
	Duration = 180,
	RunGlobally = true,
	Issueable = true,
	RunInTradePlaza = true,
	Actions = {
		"Announcement",
		"Multiplier",
		"Lighting",
		"Fish",
		"Mutation",
		"StartSound",
		"Icon"
	},
	Arguments = {
		"<b><font color='#74ff89'>GHASTLY TIDE</font></b> HAS BEGUN! (START FISHING <b>ANYWHERE!</b>)",
		{
			luck = 666,
			xp = 6,
			length = 3
		},
		"Ghastly Tide",
		{
			["The Kraken"] = 25,
			Scylla = 25,
			Mosslurker = 25,
			["Ancient Megalodon"] = 25,
			["Phantom Megalodon"] = 25,
			["Blue Whale"] = 25,
			["Colossal Blue Dragon"] = 25,
			Ghost = 40
		},
		{
			Ghastly = 100
		},
		81751962847320,
		134975450165324,
		"GHASTLY TIDE"
	}
}