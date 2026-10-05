local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Gurt Dream",
	DisplayName = "Gurt Dream Event",
	Duration = 180,
	RunGlobally = true,
	Issueable = false,
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
		"<font color='#f8bcff'>THE <b><font color='#ea30ff'>GURT DREAM</font></b> HAS TAKEN OVER!</font> (START FISHING <b>ANYWHERE!</b> [<b>20X</b> DIVINE SECRET RATES + GURTS])",
		{
			luck = 999999999999999,
			xp = 25,
			length = 3
		},
		"Gurt Dream",
		{
			["Little Gurt"] = 25,
			["🐋"] = 7,
			["🦈"] = 7,
			["🦑"] = 7,
			["🐡"] = 7,
			["🐟"] = 7,
			Banana = 7,
			["Long Pike"] = 7,
			Mustard = 7,
			Boulder = 0.002,
			["Forbidden Plesiosaur"] = 0.004,
			Seraphfin = 0.008,
			["Cataclysm Carp"] = 0.2,
			["Paradox Piranha"] = 0.1,
			Lumilotl = 0.134,
			Tuskmaw = 0.134,
			Razorfin = 0.08,
			["Crustal Colossus"] = 0.134,
			Aetherfin = 0.2,
			Him = 0.002
		},
		{
			Fabricated = 100
		},
		105286687073513,
		71829765249460,
		"Gurt Dream"
	}
}