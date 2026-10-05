local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Lucky Relic Storm",
	DisplayName = "Lucky Relic Storm Event",
	Duration = 240,
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
		"<font color = '#c490ff'><b>Relics</b> of all kinds are abundant! [AND LUCKY]</font>",
		"Relic Storm",
		{
			["Exalted Relic"] = 15,
			["Cosmic Relic"] = 10,
			["Enchant Relic"] = 25
		},
		122422179953749,
		124031479910675,
		"Lucky Relic Storm"
	}
}