local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Skies of Anguish",
	DisplayName = "Skies of Anguish",
	Duration = 300,
	RunGlobally = true,
	Issueable = true,
	RunInTradePlaza = true,
	Actions = {
		"Announcement",
		"Lighting",
		"Fish",
		"Mutation",
		"StartSound",
		"Icon"
	},
	Arguments = {
		"<font color = '#631212'><b>Skies of Anguish</b> are drifting near!</font>",
		"Skies of Anguish",
		{
			Banana = 50,
			["Tarnished Moongill"] = 20,
			["Black Iron Bucket"] = 0.1
		},
		{
			Tormented = 5
		},
		122422179953749,
		79446027316811,
		"Skies of Anguish"
	}
}