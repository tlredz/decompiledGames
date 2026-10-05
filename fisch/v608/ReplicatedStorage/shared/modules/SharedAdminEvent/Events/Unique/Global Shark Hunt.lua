local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Global Shark Hunt",
	DisplayName = "Global Shark Hunt Event",
	Duration = 60,
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
		"<font color='#ffffff'>A <b><font color='#3a8dc5'>Global Shark Hunt</font></b> has arisen from the sea.</font> (Start Fishing <b>ANYWHERE!</b>)",
		{
			xp = 1,
			length = 1
		},
		"Sharks",
		{
			["Whale Shark"] = 20,
			["Great Hammerhead Shark"] = 20,
			["Great White Shark"] = 20,
			["Cookiecutter Shark"] = 40
		},
		81751962847320,
		75393043537250,
		"Global Shark Hunt"
	}
}