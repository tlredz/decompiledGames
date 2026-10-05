local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Tentacles",
	DisplayName = "Tentacles Event",
	Duration = 240,
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
		"<b><font color='#54b2ff'>TENTACLES</font></b> ARE FALLING FROM THE SKY! (START FISHING <b>ANYWHERE!</b>)",
		{
			luck = 100,
			xp = 5,
			length = 4
		},
		"Tentacles",
		{
			["Mr. Tentacles"] = 20,
			["Cousin Tentacles"] = 15,
			["Mrs. Tentacles"] = 8,
			["Tentacles Junior"] = 8,
			["8-Bit Mr. Tentacles"] = 2,
			["Dr. Ishmael"] = 0.4
		},
		81751962847320,
		81067943650069,
		"Tentacles"
	}
}