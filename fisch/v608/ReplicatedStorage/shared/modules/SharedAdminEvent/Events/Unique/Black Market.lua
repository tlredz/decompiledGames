local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Black Market",
	DisplayName = "Black Market Event",
	Duration = 300,
	RunGlobally = true,
	Issueable = true,
	RunInTradePlaza = false,
	Actions = {
		"Announcement",
		"Lighting",
		"Rod",
		"StartSound",
		"Icon"
	},
	Arguments = {
		"The <font color = '#121212'><b>Black Market</b></font> has arrived! (At Moosewood for 10 minutes!)",
		"Black Market",
		"Black Market Spawn",
		81751962847320,
		105058501564487,
		"Black Market"
	},
	Whitelist = {
		[909635] = true
	}
}