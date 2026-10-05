local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Sandstorm",
	DisplayName = "Sandstorm Event",
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
		"<b>A <font color='#ffc58a'>SANDSTORM</font></b> HAS BEGUN! (START FISHING <b>ANYWHERE!</b>)",
		{
			luck = 25,
			xp = 15,
			length = 2
		},
		"Sandstorm",
		{
			["Sand Worm"] = 40,
			["Sand Dollar"] = 20,
			["Sandiest Dollar"] = 20,
			["Sand Tiger Shark"] = 20
		},
		{
			Sandstormy = 45,
			Sandy = 40
		},
		81751962847320,
		90639793367621,
		"SANDSTORM"
	}
}