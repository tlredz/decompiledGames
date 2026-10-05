local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Rockfall",
	DisplayName = "Rockfall Event",
	Duration = 30,
	RunGlobally = true,
	Issueable = true,
	RunInTradePlaza = true,
	Actions = {
		"Announcement",
		"Fish",
		"StartSound",
		"Icon"
	},
	Arguments = {
		"<font color='#7d7d7d'><font color='#262626'><b>ROCKS</b></font> ARE FALLING!</font> (Rocks Obtainable Globally)",
		{
			Rock = 99.999,
			Boulder = 0.001
		},
		122422179953749,
		129878767779591,
		"Rocks"
	}
}