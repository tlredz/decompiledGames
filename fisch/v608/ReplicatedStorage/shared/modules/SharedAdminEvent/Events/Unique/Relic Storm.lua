local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Relic Storm",
	DisplayName = "Relic Storm Event",
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
		"<font color = '#c490ff'><b>Relics</b> of all kinds are abundant!</font>",
		"Relic Storm",
		{
			["Exalted Relic"] = 7,
			["Cosmic Relic"] = 1,
			["Enchant Relic"] = 12
		},
		122422179953749,
		124031479910675,
		"Relic Storm"
	}
}