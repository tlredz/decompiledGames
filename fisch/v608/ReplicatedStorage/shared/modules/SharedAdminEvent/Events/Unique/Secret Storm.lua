local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Secret Storm",
	DisplayName = "Secret Storm Event",
	Duration = 180,
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
		"<font color='#ffffff'>The <b><font color='#909090'>Secret Storm</font></b> has struck.</font> (Start Fishing <b>ANYWHERE!</b>)",
		{
			luck = 1500,
			xp = 1,
			length = 3
		},
		"Secret Storm",
		{
			["🐋"] = 3,
			["🦈"] = 3,
			["🦑"] = 3,
			["🐡"] = 3,
			["🐟"] = 3,
			["Baby Bloop Fish"] = 5,
			["Bloop Cosmetic Crate"] = 5,
			["Ancient Kraken"] = 5,
			["Ancient Orca"] = 5,
			Moby = 5,
			Manatee = 5,
			["Great Goldcursed Shark"] = 5,
			Scylla = 5,
			Resin = 5,
			Banana = 5,
			["Long Pike"] = 5,
			Mustard = 5,
			["Molten Ripple"] = 5,
			["Abyssborn Monstrosity"] = 5,
			["Toilet Fish"] = 5,
			Dogefin = 5,
			["Gem Blobfish"] = 5
		},
		{
			Fortune = 20,
			Wisp = 20,
			Chilled = 20,
			Botanic = 20,
			Mango = 20
		},
		81751962847320,
		75851359982270,
		"Secret Storm"
	}
}