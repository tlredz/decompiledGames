return {
	Name = "removeskin",
	Aliases = { "remove-skin" },
	Description = "Removes a skin or multiple skins",
	Group = "Moderator",
	Args = {
		{
			Type = "players",
			Name = "players",
			Description = "The players to remove skins from."
		},
		{
			Type = "skins",
			Name = "skins",
			Description = "The skin(s) to give to the players."
		}
	}
}