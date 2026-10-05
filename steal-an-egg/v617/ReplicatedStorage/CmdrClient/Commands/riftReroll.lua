return {
	Name = "riftReroll",
	Description = "Rerolls the Rift's 3-pet ask for the players against the live banner. No free refresh is consumed.",
	Aliases = { "" },
	Group = "Admin",
	Args = {
		{
			Type = "players",
			Name = "Players",
			Description = "The players whose ask to reroll."
		}
	}
}