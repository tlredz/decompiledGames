local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Galaxy",
	DisplayName = "Galaxy Event",
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
		"ModelRain",
		"StartSound",
		"Icon"
	},
	Arguments = {
		"WE'VE TELEPORTED TO THE CENTER OF THE <b><font color='#3c26ff'>GALAXY</font></b>! (START FISHING <b>ANYWHERE!</b>)",
		{
			luck = 46838,
			xp = 5,
			length = 5
		},
		"Galaxy",
		{
			Star = 20,
			["Rocket Ship"] = 5,
			Moon = 2
		},
		{
			Galaxy = 50
		},
		"Star",
		20,
		81751962847320,
		97601030849678,
		"Galaxy"
	}
}