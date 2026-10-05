return {
	Name = "protect",
	Aliases = { "invincible" },
	Description = "Toggles a player's protected state, making them invincible to most tools.",
	Group = "Moderator",
	Args = {
		{
			Type = "players",
			Name = "players",
			Description = "The players to protect."
		}
	}
}