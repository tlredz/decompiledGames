return {
	Name = "player_setPlayerCountry",
	Aliases = {},
	Description = "Sets the player's country to the given country",
	Group = "Player",
	Args = {
		{
			Type = "player",
			Name = "player",
			Description = "Player to set the country of"
		},
		{
			Type = "string",
			Name = "country",
			Description = "Country to set the player to (US, CA, GB, AU, BR ...)"
		}
	}
}