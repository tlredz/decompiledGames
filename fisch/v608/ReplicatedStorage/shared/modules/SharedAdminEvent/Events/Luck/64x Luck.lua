local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "64x Luck",
	DisplayName = "64x Luck Event",
	Duration = 1800,
	RunGlobally = true,
	Issueable = true,
	RunInTradePlaza = true,
	Actions = { "Announcement", "Multiplier" },
	Arguments = {
		"<font color='#42ff68'><b>64x Luck</b> has begun for 30 minutes!</font>",
		{
			luck = 64,
			length = 30
		}
	}
}