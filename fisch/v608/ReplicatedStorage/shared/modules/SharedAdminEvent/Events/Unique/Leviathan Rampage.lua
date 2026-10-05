local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Leviathan Rampage",
	DisplayName = "Leviathan Rampage Event",
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
		"<font color='#ffffff'>The <b><font color='#ffffff'>LEVIATHAN RAMPAGE</font></b> has begun!</font> (Start Fishing <b>ANYWHERE!</b>)",
		{
			luck = 50000,
			xp = 2,
			length = 3
		},
		"Secret Storm",
		{
			Leviathan = 25,
			["Profane Leviathan"] = 15
		},
		{
			Madness = 30,
			Mayhem = 30
		},
		81751962847320,
		75851359982270,
		"Leviathan Rampage"
	}
}