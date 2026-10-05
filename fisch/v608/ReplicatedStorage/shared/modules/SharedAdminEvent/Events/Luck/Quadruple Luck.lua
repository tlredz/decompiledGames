local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Quadruple Luck",
	DisplayName = "Quadruple Luck Event",
	Duration = 180,
	RunGlobally = true,
	Issueable = true,
	RunInTradePlaza = true,
	Actions = { "Announcement", "Multiplier" },
	Arguments = {
		"<font color='#42ff68'><b>Quadruple Luck</b> has begun!</font>",
		{
			luck = 4,
			length = 3
		}
	}
}