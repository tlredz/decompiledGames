local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Heavenly Sparkles",
	DisplayName = "Heavenly Sparkles Event",
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
		"<b><font color='#fff7a0'>HEAVENLY SPARKLES</font></b> ARE FALLING FROM THE SKY! (START FISHING <b>ANYWHERE!</b>)",
		{
			luck = 444,
			xp = 2,
			length = 3
		},
		"Heavenly Sparkles",
		{
			["Fischipedia Accurate Pickle"] = 100
		},
		{
			Heavenly = 20,
			Lightened = 20,
			Blessed = 30,
			Celestial = 20,
			Glowy = 10
		},
		81751962847320,
		12403072872,
		"HEAVENLY SPARKLES"
	}
}