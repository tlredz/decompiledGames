return {
	Name = "cc_giveTool",
	Aliases = {},
	Description = "Give a tool to a player",
	Group = "Content Creators",
	Args = {
		{
			Type = "players",
			Name = "players",
			Description = "Players that will be given the tool",
			Optional = false
		},
		{
			Type = "toolId",
			Name = "toolName",
			Description = "Name of the tool to give",
			Optional = false
		},
		{
			Type = "number",
			Name = "delay",
			Description = "Optional delay in seconds before exploding the player",
			Optional = true
		}
	}
}