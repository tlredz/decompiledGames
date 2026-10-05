local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Spectral Tide",
	DisplayName = "Spectral Tide Event",
	Duration = 300,
	RunGlobally = true,
	Issueable = true,
	RunInTradePlaza = true,
	Actions = {
		"Announcement",
		"Multiplier",
		"Lighting",
		"Fish",
		"Mutation",
		"Rod",
		"StartSound",
		"Icon"
	},
	Arguments = {
		"<font color = '#5a4773'>A <b>Spectral Tide</b> has arrived for 5 minutes!</font> (2x XP & Spooky Finds Globally)",
		{
			xp = 2,
			length = 5
		},
		"Spectral Tide",
		{
			Poltergeist = 0.1,
			Ghoul = 1,
			Ghost = 10
		},
		{
			Soulless = 50,
			Wisp = 7,
			Haunted = 2.9,
			Spectral = 0.1
		},
		"Spiritbinder",
		79686773951838,
		125713065210734,
		"Spectral Tide"
	}
}