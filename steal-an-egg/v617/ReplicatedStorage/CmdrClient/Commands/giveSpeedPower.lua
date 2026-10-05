return {
	Name = "giveSpeedPower",
	Description = "Gives Speed to players.",
	Aliases = { "" },
	Group = "Admin",
	Args = {
		{
			Type = "players",
			Name = "Player",
			Description = "The players to give speed to."
		},
		{
			Type = "integer",
			Name = "Amount",
			Description = "The amount of speed to give."
		}
	}
}