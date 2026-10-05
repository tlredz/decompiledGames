local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Collapsed Rift",
	DisplayName = "Collapsed Rift",
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
		"THE <b><font color='#3c26ff'>GALAXY</font></b> HAS COLLAPSED! (START FISHING <b>ANYWHERE!</b>)",
		{
			luck = 232323,
			xp = 23,
			length = 2
		},
		"Collapsed Rift",
		{
			Star = 20,
			["Rocket Ship"] = 5,
			Moon = 2
		},
		{
			Galaxy = 50,
			Nova = 25,
			Lunar = 25
		},
		81751962847320,
		127359962114247,
		"Collapsed Rift"
	}
}