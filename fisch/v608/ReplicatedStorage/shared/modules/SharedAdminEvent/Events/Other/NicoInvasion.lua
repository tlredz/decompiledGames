local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "NicoInvasion",
	DisplayName = "Nico Invasion",
	Duration = 300,
	RunGlobally = true,
	Issueable = true,
	RunInTradePlaza = true,
	Actions = {
		"Announcement",
		"FishingPassives",
		"StartSound",
		"Icon"
	},
	Arguments = {
		"<font color='#fc8ca4'>A <b>wandering cat</b> has appeared by your side!</font>",
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
			_ExtraTime = 3300
		},
		117523473907553,
		98431819802289,
		"Nico Invasion"
	}
}