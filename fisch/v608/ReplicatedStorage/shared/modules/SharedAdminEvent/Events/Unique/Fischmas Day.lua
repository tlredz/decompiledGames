local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Fischmas Day",
	DisplayName = "Fischmas Day Event",
	Duration = 168,
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
		"<b><font color='#d41111'>FISCHMAS DAY</font></b> IS HERE; MERRY FISCHMAS! (START FISHING <b>ANYWHERE!</b>)",
		{
			luck = 2525,
			xp = 12,
			length = 2
		},
		"Fischmas",
		{
			["Christmas Scylla"] = 5,
			["Christmas Leviathan"] = 5,
			["Christmas Bloop Fish"] = 5,
			["Christmas Phantom Megalodon"] = 5,
			["Christmas Ancient Megalodon"] = 5,
			["Christmas Megalodon"] = 5,
			["Christmas Kraken"] = 5,
			["Christmas Ancient Kraken"] = 5,
			["Christmas Mossjaw"] = 5
		},
		{
			Gingerbread = 14.285714285714286,
			Peppermint = 14.285714285714286,
			Merry = 14.285714285714286,
			["Jingle Bell"] = 14.285714285714286,
			Frostbitten = 14.285714285714286,
			Permafrost = 14.285714285714286,
			Santa = 14.285714285714286
		},
		81751962847320,
		78476264790401,
		"Fischmas Day"
	}
}