return {
	Name = "getHttpReport",
	Aliases = {},
	Description = "Get http usage report",
	Group = "Logs",
	Args = {
		{
			Type = "boolean",
			Name = "includeTracebacks",
			Description = "includeTracebacks",
			Optional = true
		}
	}
}