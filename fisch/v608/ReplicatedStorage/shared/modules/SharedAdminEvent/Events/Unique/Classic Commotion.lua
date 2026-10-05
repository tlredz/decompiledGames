local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Classic Commotion",
	DisplayName = "Classic Commotion Event",
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
		"The <font color = '#ffe9b5'>A <b>Classic Commotion</b> is here!</font> (Classic Finds Globally)",
		{
			xp = 2,
			luck = 2,
			length = 3
		},
		"Classic Commotion",
		{
			["Enchant Relic"] = 5,
			["Hammerhead Shark"] = 5,
			["Great White Shark"] = 5,
			["Whale Shark"] = 5,
			["Mythic Fish"] = 10,
			Pufferfish = 15,
			Sunfish = 15,
			["Rubber Ducky"] = 15,
			Rabbitfish = 15,
			["Colossal Squid"] = 10
		},
		{
			Albino = 9.09,
			Darkened = 9.09,
			Electric = 9.09,
			Frozen = 9.09,
			Glossy = 9.09,
			Midas = 9.09,
			Mythical = 9.09,
			Negative = 9.09,
			Sandy = 9.09,
			Silver = 9.09,
			Translucent = 9.09
		},
		6228337171,
		107024980216042,
		"Classic Commotion"
	}
}