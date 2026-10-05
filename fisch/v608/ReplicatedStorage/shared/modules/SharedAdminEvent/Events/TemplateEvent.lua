local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Template",
	DisplayName = "Template Event",
	Duration = 60,
	RunGlobally = true,
	Issueable = true,
	RunInTradePlaza = false,
	Actions = {},
	Arguments = {}
}