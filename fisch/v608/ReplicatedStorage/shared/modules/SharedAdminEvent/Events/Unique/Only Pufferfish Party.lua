local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Only Pufferfish Party",
	DisplayName = "Only Pufferfish Party Event",
	Duration = 120,
	RunGlobally = true,
	Issueable = true,
	RunInTradePlaza = true,
	Actions = {
		"Announcement",
		"Multiplier",
		"Lighting",
		"Fish",
		"StartSound",
		"Icon"
	},
	Arguments = {
		"<font color='#edc039'>ONLY THE <b>PUFFERFISH</b> ARE PARTYING!</font>",
		{
			luck = 500,
			xp = 10,
			length = 2
		},
		"Pufferfish Party",
		{
			Pufferfish = 90,
			Mustard = 9,
			Ketchup = 1
		},
		125442582476047,
		106361610355460,
		"Only Pufferfish Party"
	}
}