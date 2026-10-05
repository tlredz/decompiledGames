local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Long Luck",
	DisplayName = "Long Luck Event",
	Duration = 10800,
	RunGlobally = true,
	Issueable = true,
	RunInTradePlaza = true,
	Actions = { "Announcement", "Multiplier" },
	Arguments = {
		"<font color='#42ff68'><b>32x Luck</b> has begun for 3 hours!</font>",
		{
			luck = 32,
			length = 180
		}
	}
}