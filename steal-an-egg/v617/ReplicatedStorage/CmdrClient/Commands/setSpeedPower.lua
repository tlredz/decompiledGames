return {
	Name = "setSpeedPower",
	Description = "Sets the player's Speed.",
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