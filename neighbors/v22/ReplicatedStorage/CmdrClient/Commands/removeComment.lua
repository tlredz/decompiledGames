return {
	Name = "removeComment",
	Description = "Removes the comment from a player",
	Group = "Moderator",
	Args = {
		{
			Type = "playerId",
			Name = "username",
			Description = "ID of player"
		},
		{
			Type = "number",
			Name = "comment ID",
			Description = "ID of comment"
		}
	}
}