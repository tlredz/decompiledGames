return {
	Name = "forceAdmin",
	Description = "Given admin permissions to a player",
	Group = "StudioDeveloper",
	Args = {
		{
			Type = "player",
			Name = "player",
			Description = "player to give admin perms to"
		},
		{
			Type = "boolean",
			Name = "true or false",
			Description = "what to set the forced admin value for the player to"
		}
	}
}