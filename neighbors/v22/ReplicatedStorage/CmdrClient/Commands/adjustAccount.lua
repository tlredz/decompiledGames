return {
	Name = "adjustAccount",
	Aliases = { "adjust-account" },
	Description = "Adjust a players account",
	Group = "SeniorModerator",
	Blacklist = { "Developer" },
	Args = {
		{
			Type = "playerId",
			Name = "username",
			Description = "player to adjust"
		}
	}
}