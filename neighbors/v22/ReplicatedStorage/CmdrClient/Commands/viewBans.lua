return {
	Name = "viewBans",
	Description = "Checks past bans of a player",
	Group = "Moderator",
	Args = {
		{
			Type = "playerId",
			Name = "username",
			Description = "ID of banned player"
		}
	}
}