return {
	Name = "awardemote",
	Aliases = { "give-emote" },
	Description = "Grants an emote to a player or set of players",
	Group = "StudioDeveloper",
	Args = {
		{
			Type = "players",
			Name = "players",
			Description = "The players to give emotes to."
		},
		{
			Type = "emotes",
			Name = "emote",
			Description = "The emotes to give to the players."
		}
	}
}