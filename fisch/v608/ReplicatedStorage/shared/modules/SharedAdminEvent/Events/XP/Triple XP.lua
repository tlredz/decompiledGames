local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Triple XP",
	DisplayName = "Triple XP Event",
	Duration = 300,
	RunGlobally = true,
	Issueable = true,
	RunInTradePlaza = true,
	Actions = { "Announcement", "Multiplier" },
	Arguments = {
		"<font color='#00e5ff'><b>Triple XP</b> has begun!</font>",
		{
			xp = 3,
			length = 5
		}
	}
}