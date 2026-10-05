local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Emoji",
	DisplayName = "Fish Emojis Event",
	Duration = 300,
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
		"🐟",
		{
			["🐟"] = 1
		},
		122422179953749,
		107149985262440,
		"🐟"
	}
}