local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Aliens",
	DisplayName = "Aliens Event",
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
		"👽 <b><font color='#38ff67'>ALIENS</font></b> HAVE ARRIVED! (START FISHING <b>ANYWHERE!</b>) 👽",
		{
			luck = 1000,
			xp = 4,
			length = 3
		},
		"Aliens",
		{
			UFO = 10,
			["Alien Hat"] = 25,
			["Alien Buddy"] = 15,
			Parasite = 25,
			JellyBop = 25
		},
		{
			Alien = 100
		},
		81751962847320,
		114812523432963,
		"Aliens"
	}
}