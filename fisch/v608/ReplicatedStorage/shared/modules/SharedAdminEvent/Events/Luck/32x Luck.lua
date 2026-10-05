local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "32x Luck",
	DisplayName = "32x Luck Event",
	Duration = 1800,
	RunGlobally = true,
	Issueable = true,
	RunInTradePlaza = true,
	Actions = { "Announcement", "Multiplier" },
	Arguments = {
		"<font color='#42ff68'><b>32x Luck</b> has begun for 30 minutes!</font>",
		{
			luck = 32,
			length = 30
		}
	}
}