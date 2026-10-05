local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Nulltide",
	DisplayName = "Nulltide Event",
	Duration = 180,
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
		"With the fading of light, the <font color = '#000000'><b>Nulltide</b></font> begins.",
		{
			luck = 20,
			xp = 4,
			length = 3
		},
		"Blackout",
		{
			Singularity = 0.01
		},
		{
			Surreal = 1
		},
		81751962847320,
		75941189959748,
		"Nulltide"
	}
}