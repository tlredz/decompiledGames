local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Verdant Vortex",
	DisplayName = "Verdant Vortex Event",
	Duration = 300,
	RunGlobally = true,
	Issueable = true,
	RunInTradePlaza = true,
	Actions = {
		"Announcement",
		"Multiplier",
		"Lighting",
		"Mutation",
		"StartSound",
		"Icon"
	},
	Arguments = {
		"<font color = '#19ff5e'>A <b>Verdant Vortex</b> has struck!</font> (50x Luck & Terrestrial Finds Globally)",
		{
			luck = 50,
			length = 5
		},
		"Verdant Vortex",
		{
			Rooted = 50,
			Botanic = 7,
			Venomous = 2.9,
			Chlorowoken = 0.1
		},
		93051327714045,
		107295741424352,
		"Verdant Vortex"
	}
}