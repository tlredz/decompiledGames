return {
	Name = "giveSakuraCrystals",
	Description = "Gives the player Sakura Crystals.",
	Aliases = { "" },
	Group = "Admin",
	Args = {
		{
			Type = "players",
			Name = "Player",
			Description = "The players to give crystals to."
		},
		{
			Type = "integer",
			Name = "Amount",
			Description = "The amount of crystals to give."
		}
	}
}