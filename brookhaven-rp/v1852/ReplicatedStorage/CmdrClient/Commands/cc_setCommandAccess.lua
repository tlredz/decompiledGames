return {
	Name = "cc_setCommandAccess",
	Aliases = {},
	Description = "Grant or revoke Content Creator commands for a player in your private server",
	Group = "Content Creators",
	Args = {
		{
			Type = "playerId",
			Name = "player",
			Description = "Player to grant or revoke command access for. Use \"#123456789\" for a user ID if they are offline.",
			Optional = false
		},
		{
			Type = "boolean",
			Name = "enabled",
			Description = "Whether that player can use Content Creator commands",
			Optional = false
		}
	}
}