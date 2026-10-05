local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "TwistedRelic",
	DisplayName = "Twisted Relic Event",
	Duration = 120,
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
		"<font color = '#311059'><b>Twisted Relics</b> are fishable!</font>",
		"Twisted Relic",
		{
			["Twisted Relic"] = 25
		},
		122422179953749,
		104028602283751,
		"Twisted Relics"
	}
}