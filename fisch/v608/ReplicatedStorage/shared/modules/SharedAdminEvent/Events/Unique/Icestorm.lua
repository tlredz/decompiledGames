local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Icestorm",
	DisplayName = "Icestorm Event",
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
		"Rod",
		"StartSound",
		"Icon"
	},
	Arguments = {
		"<font color = '#b7fffc'>An <b>Icestorm</b> is drifting near!</font> (START FISHING <b>ANYWHERE!</b>)",
		{
			luck = 50,
			xp = 8,
			length = 5
		},
		"Snowstorm",
		{
			Frostwyrm = 8,
			Fridge = 10,
			Snowman = 20,
			Snowflake = 35
		},
		{
			Frozen = 50,
			Chilled = 10,
			Snowy = 5,
			Glacial = 2,
			Permafrost = 2
		},
		"Frostbane Rod",
		111373277242126,
		126523536274302,
		"Icestorm"
	}
}