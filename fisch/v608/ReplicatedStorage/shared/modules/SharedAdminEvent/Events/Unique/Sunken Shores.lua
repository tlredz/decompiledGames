local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Sunken Shores",
	DisplayName = "Sunken Shores Event",
	Duration = 300,
	RunGlobally = true,
	Issueable = true,
	RunInTradePlaza = true,
	Actions = {
		"Announcement",
		"Multiplier",
		"Lighting",
		"Mutation",
		"StartSound"
	},
	Arguments = {
		"<font color='#ffffff'><b><font color='#3a8dc5'>Sunken Shores</font></b> have arrived!</font> (Start Fishing <b>ANYWHERE!</b>)",
		{
			luck = 5,
			xp = 1,
			length = 5
		},
		"Sharks",
		{
			Sunken = 100
		},
		81751962847320
	}
}