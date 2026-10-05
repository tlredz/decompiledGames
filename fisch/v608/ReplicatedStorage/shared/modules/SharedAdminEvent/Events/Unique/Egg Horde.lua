local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Egg",
	DisplayName = "Egg Event",
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
		"<font color='#3EB3FF'>The <b><font color='#3EB3FF'>Egg Horde</font></b> has arrived.</font> (Start Fishing <b>ANYWHERE!</b>)",
		{
			luck = 2020,
			xp = 1.2,
			length = 3
		},
		"Egg",
		{
			["Brainfreeze Egg"] = 0.1,
			["Gygax Egg"] = 7.14,
			["Shadow Egg"] = 7.14,
			["Cracked Egg"] = 7.14,
			["Puzzle Egg"] = 7.14,
			["Bouncing Egg"] = 7.14,
			["Blinking Egg"] = 7.14,
			["Stationary Egg"] = 7.14,
			["Bombastic Egg"] = 7.14,
			["Brighteyes Egg"] = 7.14,
			["Royal Egg"] = 7.14,
			["Golden Egg"] = 7.14,
			["Kind Egg"] = 7.14,
			["Wanwood Egg"] = 7.14,
			["Bluesteel Egg"] = 7.14
		},
		81751962847320,
		77037363381215,
		"Egg Horde"
	}
}