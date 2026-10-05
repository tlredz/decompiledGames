local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Narwhals",
	DisplayName = "Narwhals Event",
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
		"<font color='#ffffff'>The <b><font color='#3a8dc5'>Narwhals</font></b> have arisen from the sea!</font> (Start Fishing <b>ANYWHERE!</b>)",
		{
			luck = 101,
			xp = 1,
			length = 2
		},
		"Sharks",
		{
			Narwhal = 50,
			["Magician Narwhal"] = 25
		},
		81751962847320,
		111381609563342,
		"NARWHALS!"
	}
}