local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Volcano",
	DisplayName = "Volcano Event",
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
		"<font color='#ffffff'>The <b><font color='#f59d38'>Volcano</font></b> is erupting!</font> (Start Fishing <b>ANYWHERE!</b>)",
		{
			luck = 5000,
			xp = 3,
			length = 2
		},
		"Volcano",
		{
			["Lava Bucket"] = 10,
			Obsidian = 30,
			Basalt = 30
		},
		{
			Ember = 10,
			Emberflame = 10,
			["Ashen Fortune"] = 10,
			Inferno = 50
		},
		81751962847320,
		93992566546505,
		"Volcano"
	}
}