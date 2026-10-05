local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Mango",
	DisplayName = "Mango Event",
	Duration = 180,
	RunGlobally = true,
	Issueable = true,
	RunInTradePlaza = true,
	Actions = {
		"Announcement",
		"Multiplier",
		"Lighting",
		"Fish",
		"Mutation",
		"StartSound",
		"Icon"
	},
	Arguments = {
		"<font color='#f0b93a'>THE <b>MANGOS</b> ARE HERE!</font> (Mangos Globally)",
		{
			luck = 607,
			length = 3
		},
		"Mango",
		{
			["Mango Whale"] = 0.1,
			["Mango Smoothie"] = 2,
			Mango = 10
		},
		{
			Mango = 10
		},
		122422179953749,
		96759617106004,
		"Mango"
	}
}