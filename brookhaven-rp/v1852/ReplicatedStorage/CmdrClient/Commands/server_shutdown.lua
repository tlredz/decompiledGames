return {
	Name = "server_shutdown",
	Aliases = {},
	Description = "Shutdown the server",
	Group = "server",
	Args = {
		{
			Type = "number",
			Name = "timeInSeconds",
			Description = "The time in seconds until the server shuts down",
			Default = 0,
			Optional = true
		}
	}
}