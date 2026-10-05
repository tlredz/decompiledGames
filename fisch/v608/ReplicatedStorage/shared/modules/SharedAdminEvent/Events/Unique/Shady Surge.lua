local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Shady Surge",
	DisplayName = "Shady Surge Event",
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
		"<b><font color='#302323'><stroke color='#171111' th='2'>Shady Surge</stroke></font></b> has begun! (START FISHING <b>ANYWHERE!</b>)",
		{
			luck = 5000,
			xp = 12,
			length = 2
		},
		"Shady Surge",
		{
			["Shady Crate"] = 50,
			["Admin Bait Crate"] = 5,
			["Admin Crate"] = 5,
			["Admin Fish Barrel"] = 5
		},
		{
			Shady = 50
		},
		81751962847320,
		105058501564487,
		"Shady Surge"
	}
}