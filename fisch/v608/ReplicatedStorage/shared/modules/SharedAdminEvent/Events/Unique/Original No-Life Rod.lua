local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Original No-Life Rod",
	DisplayName = "Original No-Life Rod Event",
	Duration = 60,
	RunGlobally = true,
	Issueable = true,
	RunInTradePlaza = false,
	Actions = {
		"Announcement",
		"Lighting",
		"Rod",
		"StartSound",
		"Icon"
	},
	Arguments = {
		"The <font color = '#b32727'><b>Original No-Life Rod</b></font> is freely purchasable at Moosewood!",
		"Earthquake",
		"Original No-Life Rod",
		81751962847320,
		110071312201364,
		"Original No-Life Rod"
	}
}