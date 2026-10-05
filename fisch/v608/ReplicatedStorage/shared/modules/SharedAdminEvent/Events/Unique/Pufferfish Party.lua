local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Pufferfish Party",
	DisplayName = "Pufferfish Party Event",
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
		"<font color='#edc039'>THE <b>PUFFERFISH</b> ARE PARTYING!</font>",
		{
			luck = 500,
			xp = 10,
			length = 2
		},
		"Pufferfish Party",
		{
			Pufferfish = 15,
			["Flying Pufferfish"] = 15,
			["Blight Pufferfish"] = 15,
			Pufferflute = 15,
			["Pyrite Pufferfish"] = 15,
			["Carrot Pufferfish"] = 15,
			Mustard = 9,
			Ketchup = 1
		},
		125442582476047,
		106361610355460,
		"Pufferfish Party"
	}
}