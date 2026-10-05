return {
	Name = "givePet",
	Description = "Gives the players a pet of the given asset.",
	Aliases = { "" },
	Group = "Admin",
	Args = {
		{
			Type = "players",
			Name = "Players",
			Description = "The players to give the pet to."
		},
		{
			Type = "assetDisplayName",
			Name = "Pet",
			Description = "The asset to give, by asset name or display name."
		},
		{
			Type = "mutations",
			Name = "Mutations",
			Description = "Comma separated mutations. Defaults to none.",
			Optional = true
		},
		{
			Type = "number",
			Name = "Scale",
			Description = "Pet scale. Defaults to 1.",
			Optional = true
		},
		{
			Type = "personality",
			Name = "Personality",
			Description = "Pet personality. Defaults to a random roll.",
			Optional = true
		}
	}
}