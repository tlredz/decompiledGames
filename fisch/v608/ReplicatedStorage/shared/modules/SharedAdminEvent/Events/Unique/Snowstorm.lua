local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Snowstorm",
	DisplayName = "Snowstorm Event",
	Duration = 600,
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
		"<font color = '#b7fffc'>A <b>Snowstorm</b> is drifting near!</font> (2x Luck/XP & Chilled Finds Globally)",
		{
			luck = 2,
			xp = 2,
			length = 10
		},
		"Snowstorm",
		{
			Fridge = 0.1,
			Snowman = 1,
			Snowflake = 5
		},
		{
			Frozen = 50,
			Chilled = 10,
			Snowy = 5,
			Glacial = 2
		},
		"Frostbane Rod",
		111373277242126,
		126523536274302,
		"Snowstorm"
	}
}