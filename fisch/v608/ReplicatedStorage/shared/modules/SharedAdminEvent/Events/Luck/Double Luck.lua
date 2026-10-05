local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Double Luck",
	DisplayName = "Double Luck Event",
	Duration = 600,
	RunGlobally = true,
	Issueable = true,
	RunInTradePlaza = true,
	Actions = { "Announcement", "Multiplier" },
	Arguments = {
		"<font color='#42ff68'><b>Double Luck</b> has begun!</font>",
		{
			luck = 2,
			length = 10
		}
	}
}