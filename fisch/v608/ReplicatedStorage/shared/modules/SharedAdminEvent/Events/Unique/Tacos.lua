local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Tacos",
	DisplayName = "Tacos Event",
	Duration = 95,
	RunGlobally = true,
	Issueable = true,
	RunInTradePlaza = true,
	Actions = {
		"Announcement",
		"Multiplier",
		"Lighting",
		"Fish",
		"Mutation",
		"ModelRain",
		"StartSound",
		"Icon"
	},
	Arguments = {
		"<font color='#eb4034'>The <b><font color='#eb4034'>TACOS</font></b> are falling!!</font> (Start FISHING <b>ANYWHERE!</b>)",
		{
			luck = 100,
			length = 1
		},
		"Taco",
		{
			Taco = 30,
			["Gargantuan Taco"] = 5
		},
		{
			Spicy = 35
		},
		"Taco",
		20,
		81751962847320,
		87539476182048,
		"Tacos"
	}
}