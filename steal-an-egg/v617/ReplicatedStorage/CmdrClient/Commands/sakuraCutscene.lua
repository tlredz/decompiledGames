return {
	Name = "sakuraCutscene",
	Description = "Plays the Sakura crane unlock cutscene for the players (visual only, no unlock).",
	Aliases = { "" },
	Group = "Moderator",
	Args = {
		{
			Type = "players",
			Name = "Player",
			Description = "The players to play the cutscene for."
		}
	}
}