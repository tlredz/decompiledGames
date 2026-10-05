return {
	Name = "devprotect",
	Aliases = { "invincible" },
	Description = "Makes a player (developer) fully protected and removes cooldowns on their tools",
	Group = "StudioDeveloper",
	Args = {
		{
			Type = "players",
			Name = "players",
			Description = "The players to protect."
		}
	}
}