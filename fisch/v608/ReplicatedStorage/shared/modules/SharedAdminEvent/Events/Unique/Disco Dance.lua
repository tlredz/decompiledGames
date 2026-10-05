local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Disco Dance",
	DisplayName = "Disco Dance Event",
	Duration = 159,
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
		"THE <b><font color='#f54242'>D</font></b><b><font color='#f5c242'>I</font></b><b><font color='#bff542'>S</font></b><b><font color='#42f584'>C<b><font color='#42c8f5'>O</font></b></font></b> HAS ARRIVED! (START FISHING <b>ANYWHERE!</b>)",
		{
			luck = 26,
			xp = 20,
			length = 2
		},
		"Disco Dance",
		{
			["Disco Ball"] = 20,
			["Incredibly Large Disco Ball"] = 5,
			["Dance Floor"] = 20,
			Microphone = 20
		},
		{
			Mythical = 50
		},
		89604324486565,
		72393900417607,
		"Disco Dance"
	}
}