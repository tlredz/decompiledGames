local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Earthquake",
	DisplayName = "Earthquake Event",
	Duration = 180,
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
		"AN <b><font color='#eb4034'>EARTHQUAKE</font></b> HAS STRUCK! (START FISHING <b>ANYWHERE!</b>)",
		{
			luck = 20000,
			xp = 2,
			length = 3
		},
		"Earthquake",
		{
			Charybdis = 5,
			Lusca = 5,
			Akkorokamui = 5
		},
		81751962847320,
		95263963423674,
		"EARTHQUAKE"
	}
}