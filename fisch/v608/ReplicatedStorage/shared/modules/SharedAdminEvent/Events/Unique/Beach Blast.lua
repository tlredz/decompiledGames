local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Beach Blast",
	DisplayName = "Beach Blast Event",
	Duration = 60,
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
		"<font color='#ffd86e'>THE <b>BEACH BLAST</b> IS HERE!</font>",
		{
			luck = 50,
			xp = 10,
			length = 1
		},
		"Beach Blast",
		{
			["Palm Tree"] = 20,
			["Beach Umbrella"] = 20,
			Sunhat = 20
		},
		{
			Sandy = 40,
			Beached = 40
		},
		122422179953749,
		109292857212742,
		"Beach Blast"
	}
}