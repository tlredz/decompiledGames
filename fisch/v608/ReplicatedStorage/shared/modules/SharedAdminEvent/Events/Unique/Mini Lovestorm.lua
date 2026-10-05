local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Mini Lovestorm",
	DisplayName = "Mini Lovestorm Event",
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
		"A <b><font color='#fd96ff'>MINI LOVESTORM</font></b> HAS APPEARED! (START FISHING <b>ANYWHERE!</b>)",
		{
			luck = 214,
			xp = 4,
			length = 2
		},
		"Mini Lovestorm",
		{
			["Baby Lovestorm Eel"] = 10,
			["Baby Lovestorm Turtle"] = 10
		},
		{
			Sweet = 15,
			Lovely = 15,
			Candy = 15
		},
		1839901317,
		70822794044383,
		"Mini Lovestorm"
	}
}