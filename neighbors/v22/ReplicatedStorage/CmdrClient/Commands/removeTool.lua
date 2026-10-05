return {
	Name = "removetool",
	Aliases = { "remove-tool" },
	Description = "Removes a tool or multiple tools from a player or set of players",
	Group = "Moderator",
	Args = {
		{
			Type = "players",
			Name = "players",
			Description = "The players to give tools to."
		},
		{
			Type = "tools",
			Name = "tools",
			Description = "The tool to give to the players."
		}
	}
}