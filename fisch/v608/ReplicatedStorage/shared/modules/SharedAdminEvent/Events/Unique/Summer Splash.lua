local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Summer Splash",
	DisplayName = "Summer Splash Event",
	Duration = 153,
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
		"<font color='#ffca6e'>The</font> <b><font color='#4ad8ff'>SUMMER SPLASH</font></b> <font color='#ffca6e'>HAS ARRIVED!</font> (START FISHING <b>ANYWHERE!</b>)",
		{
			luck = 6202026,
			xp = 10,
			length = 2
		},
		"Summer Splash",
		{
			["Summer Scylla"] = 15,
			["Summer Leviathan"] = 15,
			["Summer Bloop Fish"] = 15,
			["Summer Megalodon"] = 15,
			["Summer Reef Titan"] = 15
		},
		{
			Paradise = 5.882352941176471,
			Beached = 5.882352941176471,
			Tropical = 5.882352941176471,
			Sandy = 5.882352941176471,
			Beachy = 5.882352941176471,
			Popsicle = 5.882352941176471,
			Summer = 5.882352941176471,
			Tanned = 5.882352941176471,
			["Super-Tanned"] = 5.882352941176471,
			Splashed = 5.882352941176471,
			Tiki = 5.882352941176471,
			Creamsicle = 5.882352941176471,
			Floatie = 5.882352941176471,
			["Beach Ball"] = 5.882352941176471,
			Starshell = 5.882352941176471,
			["Sand Castled"] = 5.882352941176471,
			Lemon = 5.882352941176471
		},
		89604324486565,
		104750143744824,
		"Summer Splash"
	}
}