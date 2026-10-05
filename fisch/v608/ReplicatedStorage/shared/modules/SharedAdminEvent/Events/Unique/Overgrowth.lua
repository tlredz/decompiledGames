local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Overgrowth",
	DisplayName = "Overgrowth Event",
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
		"<font color='#ffffff'>The <b><font color='#0B6623'>Forest</font></b> awakens.</font> (Start Fishing <b>ANYWHERE!</b>)",
		{
			luck = 50,
			xp = 1,
			length = 5
		},
		"Overgrowth",
		{
			Venoblossom = 1,
			["Pine Tree"] = 10,
			Fern = 35
		},
		{
			["Brown Wood"] = 25,
			Oak = 25,
			["Green Leaf"] = 25,
			["Mother Nature"] = 25
		},
		81751962847320,
		125559923307873,
		"Overgrowth"
	}
}