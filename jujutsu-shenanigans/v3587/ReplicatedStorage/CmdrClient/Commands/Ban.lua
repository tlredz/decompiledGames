return {
	Name = "ban",
	Description = "Removes the player's ability to join the game along with their place in the leaderboards",
	Group = {
		"Owner",
		"Developer",
		"HeadMod",
		"Mod"
	},
	Args = {
		{
			Type = "username",
			Name = "Username"
		},
		{
			Type = "reason",
			Name = "Reason",
			Optional = true
		},
		{
			Type = "number",
			Name = "Duration (in days)",
			Optional = true
		},
		{
			Type = "boolean",
			Name = "Include Alternative Accounts",
			Optional = true
		}
	}
}