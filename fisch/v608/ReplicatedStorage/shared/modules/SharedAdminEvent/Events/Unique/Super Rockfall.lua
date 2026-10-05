local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Super Rockfall",
	DisplayName = "Super Rockfall Event",
	Duration = 120,
	RunGlobally = true,
	Issueable = false,
	RunInTradePlaza = true,
	Actions = {
		"Announcement",
		"Fish",
		"StartSound",
		"Icon"
	},
	Arguments = {
		"MORE <font color='#7d7d7d'><font color='#262626'><b>ROCKS</b></font> ARE FALLING!</font> (Dave and Rocks Obtainable Globally)",
		{
			Rock = 79.9,
			Dave = 20,
			Boulder = 0.1
		},
		122422179953749,
		129878767779591,
		"Super Rockfall"
	}
}