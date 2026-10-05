local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Heatwave",
	DisplayName = "Heatwave Event",
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
		"<font color='#ffffff'>A <b><font color='#f56e38'>HEATWAVE</font></b> is coming!</font> (Start Fishing <b>ANYWHERE!</b>)",
		{
			luck = 600,
			xp = 6,
			length = 2
		},
		"Heatwave",
		{
			["Glass Sand Castle"] = 40,
			["Scorching Umbrella"] = 25,
			Sun = 5
		},
		{
			Ember = 15,
			Emberflame = 15,
			Solarblaze = 15,
			Charred = 15,
			Tanned = 15,
			Umbra = 15,
			Inferno = 15
		},
		81751962847320,
		103680573935204,
		"Heatwave"
	}
}