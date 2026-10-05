return {
	Name = "giveMonstrousEgg",
	Description = "Gives the players a Parasite Egg, the Monster Chest jackpot egg.",
	Group = "Admin",
	Args = {
		{
			Type = "players",
			Name = "Players",
			Description = "The players to give the egg to."
		},
		{
			Type = "assetName",
			Name = "Egg",
			Description = "The asset the egg hatches into. Defaults to a chest roll.",
			Optional = true
		},
		{
			Type = "number",
			Name = "Scale",
			Description = "Egg scale. Defaults to 1.",
			Optional = true
		}
	}
}