local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Double XP",
	DisplayName = "Double XP Event",
	Duration = 600,
	RunGlobally = true,
	Issueable = true,
	RunInTradePlaza = true,
	Actions = { "Announcement", "Multiplier" },
	Arguments = {
		"<font color='#00e5ff'><b>Double XP</b> has begun!</font>",
		{
			xp = 2,
			length = 10
		}
	}
}