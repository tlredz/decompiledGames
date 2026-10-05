return {
	Name = "follow",
	Aliases = { "gotoplayer" },
	Description = "Join another player's server. Only teleports you.",
	Group = "QALEAD",
	Args = {
		{
			Type = "playerId",
			Name = "Target",
			Description = "The username or #UserId of the player to join."
		}
	}
}