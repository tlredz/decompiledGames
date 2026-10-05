local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Sunken Seas Storm",
	DisplayName = "Sunken Seas Storm",
	Duration = 120,
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
		"<b><font color='#82ffb0'>SUNKEN SEAS STORM</font></b> HAS BEGUN! (START FISHING <b>ANYWHERE!</b>)",
		{
			luck = 1000,
			xp = 1.5,
			length = 2
		},
		"Sunken Seas Storm",
		{
			["The Kraken"] = 10,
			Scylla = 10,
			Mosslurker = 10,
			["Ancient Megalodon"] = 10,
			["Phantom Megalodon"] = 10,
			["Colossal Blue Dragon"] = 10
		},
		{
			Sunken = 1000
		},
		81751962847320,
		85882142661350,
		"SUNKEN SEAS STORM"
	}
}