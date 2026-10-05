local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Clover Storm",
	DisplayName = "Clover Storm Event",
	Duration = 180,
	RunGlobally = true,
	Issueable = true,
	RunInTradePlaza = true,
	Actions = {
		"Announcement",
		"Multiplier",
		"Mutation",
		"StartSound",
		"Icon"
	},
	Arguments = {
		"<b><font color='#9bffa2'>Lucky Clovers</font></b> are falling from the sky! (LUCK IS <b>DRASTICALLY</b> INCREASED!)",
		{
			luck = 10000000,
			xp = 3,
			length = 3
		},
		{
			["Lucky Gold"] = 20,
			Clover = 20
		},
		81751962847320,
		121320367381648,
		"Clover Storm"
	}
}