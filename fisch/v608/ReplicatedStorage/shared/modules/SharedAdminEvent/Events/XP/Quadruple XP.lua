local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Quadruple XP",
	DisplayName = "Quadruple XP Event",
	Duration = 180,
	RunGlobally = true,
	Issueable = true,
	RunInTradePlaza = true,
	Actions = { "Announcement", "Multiplier" },
	Arguments = {
		"<font color='#00e5ff'><b>Quadruple XP</b> has begun!</font>",
		{
			xp = 4,
			length = 3
		}
	}
}