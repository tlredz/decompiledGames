local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "CosmicRelic",
	DisplayName = "Cosmic Relics",
	Duration = 360,
	RunGlobally = true,
	Issueable = true,
	RunInTradePlaza = true,
	Actions = {
		"Announcement",
		"Lighting",
		"Fish",
		"StartSound",
		"Icon"
	},
	Arguments = {
		"<font color = '#7773ff'><b>Cosmic Relics</b> are fishable!</font>",
		"Cosmic Relic",
		{
			["Cosmic Relic"] = 0.5
		},
		122422179953749,
		80055965949958,
		"Cosmic Relics"
	}
}