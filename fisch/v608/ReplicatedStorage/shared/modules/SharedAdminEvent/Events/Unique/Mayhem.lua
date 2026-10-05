local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Mayhem",
	DisplayName = "Mayhem Event",
	Duration = 300,
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
		"<b><font color='#000000'><stroke color='#ffffff' th='2'>MAYHEM</stroke></font></b> HAS BEGUN! (START FISHING <b>ANYWHERE!</b>)",
		{
			luck = 5000,
			xp = 3,
			length = 5
		},
		"Mayhem",
		{
			["Golden Nessie"] = 3,
			["Golden Scylla"] = 5,
			["Golden Coin"] = 6,
			["Black Iron Bucket"] = 1,
			Poltergeist = 3,
			Ghoul = 5,
			Ghost = 6,
			Fridge = 3,
			Snowman = 5,
			Snowflake = 6,
			Flashlight = 5,
			Singularity = 2,
			["🐋"] = 5,
			["🦈"] = 5,
			["🦑"] = 5,
			["🐡"] = 5,
			["🐟"] = 5,
			["Baby Bloop Fish"] = 5,
			["Bloop Cosmetic Crate"] = 5,
			["Ancient Kraken"] = 4,
			["Ancient Orca"] = 4,
			Moby = 4,
			["Bloop Fish"] = 3
		},
		{
			Tormented = 6.666666666666667,
			Lightened = 6.666666666666667,
			Surreal = 6.666666666666667,
			Radiant = 6.666666666666667,
			Mace = 6.666666666666667,
			Spectral = 6.666666666666667,
			Glacial = 6.666666666666667,
			Chlorowoken = 6.666666666666667,
			Female = 6.666666666666667,
			Lustrous = 6.666666666666667,
			Haunted = 6.666666666666667,
			Venomous = 6.666666666666667,
			Chilled = 6.666666666666667,
			Mango = 6.666666666666667,
			Mayhem = 6.666666666666667
		},
		81751962847320,
		94402287239574,
		"MAYHEM"
	}
}