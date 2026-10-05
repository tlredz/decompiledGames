local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Subspace Destruction",
	DisplayName = "Subspace Destruction Event",
	Duration = 240,
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
		"<font color='#ff3798'>The <b><font color='#ff3798'>Subspaces</font></b> are here...</font> (Don't let them <b>EXPLODE!</b>)",
		{
			luck = 1500,
			xp = 5,
			length = 4
		},
		"DestructionMine",
		{
			["Default Subspace Tripmine"] = 30,
			["Nicely Sized Tripmine"] = 15,
			["Vast Tripmine"] = 0.3,
			["Pocket Sized Tripmine"] = 54
		},
		{
			Photical = 30,
			Subspace = 40,
			Madness = 20,
			Darkheart = 10
		},
		108345344203629,
		97774604696056,
		"Subspace Destruction"
	}
}