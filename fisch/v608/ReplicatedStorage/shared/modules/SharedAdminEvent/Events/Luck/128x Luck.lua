local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "128x Luck",
	DisplayName = "128x Luck Event",
	Duration = 1800,
	RunGlobally = true,
	Issueable = true,
	RunInTradePlaza = true,
	Actions = { "Announcement", "Multiplier" },
	Arguments = {
		"<font color='#42ff68'><b>128x Luck</b> has begun for 30 minutes!</font>",
		{
			luck = 128,
			length = 30
		}
	}
}