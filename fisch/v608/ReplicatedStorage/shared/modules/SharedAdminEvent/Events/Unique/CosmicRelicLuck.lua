local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "CosmicRelicLuck",
	DisplayName = "Lucky Cosmic Relics",
	Duration = 180,
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
		"<font color = '#7773ff'><b>Cosmic Relics</b> are commonly fishable!</font>",
		"Cosmic Relic",
		{
			["Cosmic Relic"] = 15
		},
		122422179953749,
		80055965949958,
		"Lucky Cosmic Relics"
	}
}