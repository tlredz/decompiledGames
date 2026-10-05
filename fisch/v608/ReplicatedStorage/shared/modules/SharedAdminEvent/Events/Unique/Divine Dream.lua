local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Divine Dream",
	DisplayName = "Divine Dream Event",
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
		"<font color='#e0bcff'>THE <b><font color='#7575ff'>DIVINE DREAM</font></b> HAS TAKEN OVER!</font> (START FISHING <b>ANYWHERE!</b> [<b>10X</b> DIVINE SECRET RATES])",
		{
			luck = 999999999999999,
			xp = 20,
			length = 2
		},
		"Divine Dream",
		{
			["🐋"] = 5,
			["🦈"] = 5,
			["🦑"] = 5,
			["🐡"] = 5,
			["🐟"] = 5,
			Banana = 5,
			["Long Pike"] = 5,
			Mustard = 5,
			Boulder = 0.001,
			["Forbidden Plesiosaur"] = 0.002,
			Seraphfin = 0.004,
			["Cataclysm Carp"] = 0.1,
			["Paradox Piranha"] = 0.05,
			Lumilotl = 0.067,
			Tuskmaw = 0.067,
			Razorfin = 0.04,
			["Crustal Colossus"] = 0.067,
			Aetherfin = 0.1,
			Him = 0.001
		},
		{
			Fabricated = 100
		},
		105286687073513,
		120196334844770,
		"Divine Dream"
	}
}