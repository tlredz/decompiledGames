return {
	Name = "player_followPlayer",
	Aliases = {},
	Description = "Joins the players server",
	Group = "Player",
	Args = {
		{
			Type = "player",
			Name = "player",
			Description = "The player who will be sent",
			Optional = false
		},
		{
			Type = "string",
			Name = "target_username",
			Description = "Target user name",
			Optional = false
		}
	}
}