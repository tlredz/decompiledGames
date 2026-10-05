local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Buffed Goldstorm",
	DisplayName = "Buffed Goldstorm Event",
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
		"<font color='#f0d13a'>A <b>Buffed Goldstorm</b> has struck!</font> (3x Sell Rate & Golden Finds Globally)",
		{
			sell = 2
		},
		"Goldstorm",
		{
			["Golden Nessie"] = 3,
			["Golden Scylla"] = 10,
			["Golden Coin"] = 20
		},
		{
			Golden = 50,
			Fortune = 30,
			Lustrous = 20,
			Radiant = 10
		},
		136674910109525,
		107301686592441,
		"Buffed Goldstorm"
	}
}