local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "1.1x Luck",
	DisplayName = "1.1x Luck Event",
	Duration = 10,
	RunGlobally = true,
	Issueable = true,
	RunInTradePlaza = true,
	Actions = { "Announcement", "Multiplier" },
	Arguments = {
		"<font color='#42ff68'><b>1.1x Luck</b> has begun!</font>",
		{
			luck = 1.1,
			length = 0
		}
	}
}