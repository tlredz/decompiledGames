local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Crates",
	DisplayName = "Crates Event",
	Duration = 120,
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
		"Exclusive <b><font color='#C1A8D3'>Crates</font></b> ARE HERE! (START FISHING <b>ANYWHERE!</b>)",
		{
			luck = 500,
			xp = 5,
			length = 2
		},
		"Crates",
		{
			["Admin Bait Crate"] = 20,
			["Admin Crate"] = 20,
			["Admin Fish Barrel"] = 20
		},
		81751962847320,
		84989881492296,
		"Crates"
	}
}