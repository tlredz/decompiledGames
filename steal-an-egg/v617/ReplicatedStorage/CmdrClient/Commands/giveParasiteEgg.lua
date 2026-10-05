return {
	Name = "giveParasiteEgg",
	Description = "Gives the players an egg with a Monster Parasite attached, for testing.",
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
			Description = "The asset the egg hatches into."
		},
		{
			Type = "number",
			Name = "Scale",
			Description = "Egg scale. Defaults to 1.",
			Optional = true
		}
	}
}