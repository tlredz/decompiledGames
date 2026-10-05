local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Christmas Tide",
	DisplayName = "Christmas Tide Event",
	Duration = 115,
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
		"The <b><font color='#f54242'>CHRISTMAS TIDE</font></b> HAS ARRIVED! (START FISHING <b>ANYWHERE!</b>)",
		{
			luck = 2525,
			xp = 6,
			length = 1
		},
		"Crates",
		{
			["Christmas Scylla"] = 15,
			["Christmas Leviathan"] = 8,
			["Christmas Bloop Fish"] = 3
		},
		{
			Gingerbread = 33.333333333333336,
			Peppermint = 33.333333333333336,
			Merry = 33.333333333333336
		},
		81751962847320,
		78476264790401,
		"Christmas Tide"
	}
}