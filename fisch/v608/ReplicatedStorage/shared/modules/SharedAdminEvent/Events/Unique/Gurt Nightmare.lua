local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Gurt Nightmare",
	DisplayName = "Gurt Nightmare Event",
	Duration = 180,
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
		"<font color='#f8bcff'>THE <b><font color='#630000'>GURT NIGHTMARE</font></b> HAS TAKEN OVER!</font> (START FISHING <b>ANYWHERE!</b> [EVIL GURTS])",
		{
			luck = 999999999999999,
			xp = 25,
			length = 3
		},
		"Gurt Nightmare",
		{
			["Evil Gurt"] = 25
		},
		105286687073513,
		134258340848881,
		"Gurt Nightmare"
	}
}