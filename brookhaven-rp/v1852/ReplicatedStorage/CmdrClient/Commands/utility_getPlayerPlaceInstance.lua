return {
	Name = script.Name,
	Aliases = {},
	Description = "Get a player's place instance",
	Group = "Utility",
	Args = {
		{
			Type = "string",
			Name = "PlayerUserName",
			Description = "The player to get the place instance of",
			Optional = true
		}
	}
}