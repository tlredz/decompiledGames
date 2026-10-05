local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Emojis",
	DisplayName = "All Fish Emojis Event",
	Duration = 180,
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
		"🐟 🦑 🦈 🐋 🐡",
		{
			["🐟"] = 1,
			["🦑"] = 1,
			["🦈"] = 1,
			["🐋"] = 1,
			["🐡"] = 1
		},
		122422179953749,
		85156201776305,
		"EMOJIS!"
	}
}