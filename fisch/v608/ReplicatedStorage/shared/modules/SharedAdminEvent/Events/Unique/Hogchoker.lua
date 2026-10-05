local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Hogchoker",
	DisplayName = "Hogchoker Event",
	Duration = 60,
	RunGlobally = true,
	Issueable = false,
	RunInTradePlaza = false,
	Actions = {
		"Announcement",
		"Fish",
		"Mutation",
		"StartSound",
		"Icon"
	},
	Arguments = {
		"get ur emberflame hogchokers",
		{
			Hogchoker = 50
		},
		{
			Emberflame = 50
		},
		122422179953749,
		77825372078181,
		"Emberflame Hogchokers"
	}
}