local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Semi Chaos",
	DisplayName = "Semi Chaos Event",
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
		"<font color='#ffffff'>THE <b><font color='#000000'><stroke color='#ffffff' th='2'>SEMI CHAOS</stroke></font></b> HAS ARRIVED!</font> (START FISHING <b>ANYWHERE!</b>)",
		{
			luck = 800,
			xp = 3,
			length = 5
		},
		"Pure Chaos",
		{
			["Golden Nessie"] = 1,
			["Golden Scylla"] = 3,
			["Golden Coin"] = 5,
			["Black Iron Bucket"] = 1,
			Poltergeist = 1,
			Ghoul = 3,
			Ghost = 5,
			Fridge = 1,
			Snowman = 3,
			Snowflake = 5,
			Flashlight = 3,
			Singularity = 1,
			["🐋"] = 3,
			["🦈"] = 3,
			["🦑"] = 3,
			["🐡"] = 3,
			["🐟"] = 3,
			["Baby Bloop Fish"] = 3,
			["Bloop Cosmetic Crate"] = 3,
			["Ancient Kraken"] = 4,
			["Ancient Orca"] = 4,
			Moby = 4,
			["Bloop Fish"] = 1
		},
		{
			Tormented = 12.5,
			Lightened = 12.5,
			Surreal = 12.5,
			Radiant = 12.5,
			Mace = 12.5,
			Spectral = 12.5,
			Glacial = 12.5,
			Chlorowoken = 12.5
		},
		81751962847320,
		96569572868598,
		"Semi Chaos"
	}
}