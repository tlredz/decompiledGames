local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Plague Terror",
	DisplayName = "Plague Terror Event",
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
		"<font color='#53395f'>The <b><font color='#53395f'>Plague Terror</font></b> has spread..</font> (Don't get <b>INFECTED!</b>)",
		{
			luck = 750,
			xp = 7,
			length = 5
		},
		"PlagueTerrorMine",
		{
			Rotbloom = 15,
			Witherbloom = 10,
			Mossjaw = 15,
			["Elder Mossjaw"] = 10,
			["Toxic Guardian"] = 10
		},
		{
			Plagued = 35,
			Mossy = 10,
			Madness = 10
		},
		9126213995,
		98762583387551,
		"Plague Terror"
	}
}