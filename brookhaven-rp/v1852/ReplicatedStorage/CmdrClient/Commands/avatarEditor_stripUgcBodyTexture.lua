return {
	Name = script.Name,
	Aliases = {},
	Description = "Strips the Skye/Brian body texture so body color and 2D clothing show, bypassing the Franchise place check",
	Group = "Utility",
	Args = {
		{
			Type = "players",
			Name = "players",
			Description = "Players wearing the Skye or Brian bundle (defaults to you)",
			Optional = true
		}
	}
}