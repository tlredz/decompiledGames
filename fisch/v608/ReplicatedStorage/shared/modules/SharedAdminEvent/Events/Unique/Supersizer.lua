local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Supersizer",
	DisplayName = "Supersizer Event",
	Duration = 180,
	RunGlobally = true,
	Issueable = true,
	RunInTradePlaza = true,
	Actions = {
		"Announcement",
		"Multiplier",
		"Fish",
		"StartSound",
		"Icon"
	},
	Arguments = {
		"Things are getting <b><font color='#000000'><stroke color='#ffffff' th='2'>Supersized</stroke></font></b>! (START FISHING <b>ANYWHERE!</b>)",
		{
			luck = 1000,
			xp = 3,
			length = 3
		},
		{
			["Supersized Driftwood"] = 10,
			["Supersized Scylla"] = 5,
			["Supersized Mosslurker"] = 10,
			["Supersized Bloop Fish"] = 10,
			["Supersized Floppy"] = 10,
			["Supersized Sea Pickle"] = 10
		},
		81751962847320,
		133180807648033,
		"Supersizer"
	}
}