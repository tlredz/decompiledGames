return {
	Name = "client_toggleNoClip",
	Aliases = {},
	Description = "Toggle no clip for a player",
	Group = "Client",
	Args = {
		{
			Type = "player",
			Name = "player",
			Description = "Player to toggle no clip for",
			Optional = false
		},
		{
			Type = "boolean",
			Name = "enabled",
			Description = "Whether to enable or disable no clip",
			Optional = false
		}
	}
}