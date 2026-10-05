local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Bloopfishes",
	DisplayName = "Bloop Fishes Event",
	Duration = 300,
	RunGlobally = true,
	Issueable = true,
	RunInTradePlaza = true,
	Actions = {
		"Announcement",
		"Lighting",
		"Fish",
		"StartSound",
		"Icon"
	},
	Arguments = {
		"<font color='#cdccfc'><font color='#7A7266'><b>Bloop Fishes</b></font> are near!</font> (Bloop Fish Obtainable Globally)",
		"Bloop Fishes",
		{
			["Bloop Fish"] = 2
		},
		122422179953749,
		116309304806549,
		"Bloop Fishes"
	}
}