local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Goldstorm",
	DisplayName = "Goldstorm Event",
	Duration = 120,
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
		"<font color='#f0d13a'>A <b>Goldstorm</b> has struck!</font> (Improved Sell Rate & Golden Finds Globally)",
		{
			sell = 0.25
		},
		"Goldstorm",
		{
			["Golden Nessie"] = 0.01,
			["Golden Scylla"] = 0.1,
			["Golden Coin"] = 5
		},
		{
			Golden = 50,
			Fortune = 7,
			Lustrous = 2.9,
			Radiant = 0.1
		},
		136674910109525,
		107301686592441,
		"Goldstorm"
	}
}