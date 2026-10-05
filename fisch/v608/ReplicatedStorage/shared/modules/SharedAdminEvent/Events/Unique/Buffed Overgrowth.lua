local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Buffed Overgrowth",
	DisplayName = "Buffed Overgrowth Event",
	Duration = 300,
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
		"<font color='#ffffff'>THE <b><font color='#0B6623'>FOREST</font></b> AWAKENS!</font> (Start Fishing <b>ANYWHERE!</b>)",
		{
			luck = 5000,
			xp = 13.33,
			length = 5
		},
		"Overgrowth",
		{
			Venoblossom = 10,
			["Pine Tree"] = 30,
			Fern = 45
		},
		{
			["Brown Wood"] = 25,
			Oak = 25,
			["Green Leaf"] = 25,
			["Mother Nature"] = 25
		},
		81751962847320,
		125559923307873,
		"Buffed Overgrowth"
	}
}