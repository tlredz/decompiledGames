local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Rainstorm",
	DisplayName = "Rainstorm Event",
	Duration = 300,
	RunGlobally = true,
	Issueable = true,
	RunInTradePlaza = true,
	Actions = {
		"Announcement",
		"Multiplier",
		"Lighting",
		"Fish",
		"StartSound",
		"Icon"
	},
	Arguments = {
		"<font color='#ffffff'>A sudden <b><font color='#99e7ff'>Rainstorm</font></b> has appeared.</font> (Start Fishing <b>ANYWHERE!</b>)",
		{
			luck = 5,
			xp = 1,
			length = 5
		},
		"Rainstorm",
		{
			["Lightning Bolt"] = 1,
			Cloud = 15,
			Raindrop = 50
		},
		81751962847320,
		80820899013346,
		"Rainstorm"
	}
}