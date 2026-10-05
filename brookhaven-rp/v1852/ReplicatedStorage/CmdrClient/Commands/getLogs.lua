return {
	Name = "getLogs",
	Aliases = {},
	Description = "Get logs",
	Group = "Logs",
	Args = {
		{
			Type = "player",
			Name = "player",
			Description = "Player to get client logs for",
			Optional = true
		},
		{
			Type = "number",
			Name = "limit",
			Description = "Limit of logs to get",
			Default = 400
		},
		{
			Type = "boolean",
			Name = "clientLogsOnly",
			Description = "Set this to true to only get client logs",
			Optional = true
		}
	}
}