return {
	Name = "awardbundle",
	Aliases = { "give-bundle" },
	Description = "Awards a player or set of players a bundle",
	Group = "StudioDeveloper",
	Args = {
		{
			Type = "player",
			Name = "player",
			Description = "The player to give bundle to."
		},
		{
			Type = "bundles",
			Name = "BundleName",
			Description = "Name of the bundle to give."
		}
	}
}