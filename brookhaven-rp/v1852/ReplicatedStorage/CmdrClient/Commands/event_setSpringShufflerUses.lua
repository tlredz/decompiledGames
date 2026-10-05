return {
	Name = "event_setSpringShufflerUses",
	Aliases = {},
	Description = "Set the Easter 2026 Spring Shuffler uses for a player",
	Group = "Event",
	Args = {
		{
			Type = "player",
			Name = "player",
			Description = "Player that will have their Spring Shuffler uses updated",
			Optional = false
		},
		{
			Type = "number",
			Name = "newUseCount",
			Description = "The new use count for the player",
			Optional = false
		}
	}
}