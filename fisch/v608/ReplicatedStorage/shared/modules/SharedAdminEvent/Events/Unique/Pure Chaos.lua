local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Pure Chaos",
	DisplayName = "Pure Chaos Event",
	Duration = 360,
	RunGlobally = true,
	Issueable = false,
	RunInTradePlaza = false,
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
		"<font color='#ffffff'>THE ONE-TIME <b><font color='#000000'><stroke color='#ffffff' th='2'>PURE CHAOS</stroke></font></b> HAS ARRIVED!</font> (START FISHING <b>ANYWHERE!</b>)",
		{
			luck = 1000,
			xp = 5,
			length = 6
		},
		"Pure Chaos",
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
		"Pure Chaos"
	}
}