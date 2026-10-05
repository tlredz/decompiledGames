local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "NicoInvasion2",
	DisplayName = "Nico Invasion (But Fishable!)",
	Duration = 240,
	RunGlobally = true,
	Issueable = true,
	RunInTradePlaza = true,
	Actions = {
		"Announcement",
		"Fish",
		"Mutation",
		"FishingPassives",
		"StartSound",
		"Icon"
	},
	Arguments = {
		"<font color='#fc8ca4'>A <b>wandering cat</b> has appeared by your side; and cats seem to be swimming in the water!</font>",
		{
			Nico = 30,
			["Colossal Nico"] = 5,
			["Extra Colossal Nico"] = 1,
			["Comically Ginormous Nico"] = 0.1
		},
		{
			["Nico's Nyantics"] = 20,
			Skrunkly = 20
		},
		{
			["Nico's Yarncaster"] = {
				BobberMutationPool = {},
				NicoMutationPool = {},
				TargetBobber = "Clownfish Cat Toy",
				FollowTime = 0.2,
				SleepInterval = 15,
				SleepToggleChance = 40,
				IdleTimeBeforeDive = 60,
				DiveChance = 33,
				TugInterval = 60000,
				TugChance = 0,
				TugDuration = 0,
				TugStrength = 0
			},
			_ExtraTime = 300
		},
		117523473907553,
		98431819802289,
		"Nico Invasion"
	}
}