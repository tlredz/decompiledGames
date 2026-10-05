return {
	Name = "setMoney",
	Description = "Sets the player money.",
	Aliases = { "" },
	Group = "Admin",
	Args = {
		{
			Type = "players",
			Name = "Player",
			Description = "The players to give money to."
		},
		{
			Type = "integer",
			Name = "Amount",
			Description = "The amount of money to give."
		}
	}
}