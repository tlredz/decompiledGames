local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Blackout",
	DisplayName = "Blackout Event",
	Duration = 60,
	RunGlobally = true,
	Issueable = true,
	RunInTradePlaza = false,
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
		"A <font color = '#000000'><b>Blackout</b></font> has occurred!",
		{
			luck = 10,
			xp = 3,
			length = 1
		},
		"Blackout",
		{
			Flashlight = 1
		},
		{
			Lightened = 5,
			Darkened = 50
		},
		81751962847320,
		109164994678918,
		"Blackout"
	}
}