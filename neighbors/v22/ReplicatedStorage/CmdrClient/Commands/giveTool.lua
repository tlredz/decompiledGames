return {
	Name = "awardtool",
	Aliases = { "give-tool" },
	Description = "Awards a player or set of players a tool or multiple tools",
	Group = "StudioDeveloper",
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