return {
	Name = "setFireworkUses",
	Aliases = {},
	Description = "Set paid firework uses for a player (GalaxySpiral or HeartBurst)",
	Group = "Event",
	Args = {
		{
			Type = "player",
			Name = "player",
			Description = "Player to update",
			Optional = false
		},
		{
			Type = "fireworkType",
			Name = "fireworkType",
			Description = "GalaxySpiral or HeartBurst",
			Optional = false
		},
		{
			Type = "number",
			Name = "newUseCount",
			Description = "Exact remaining uses",
			Optional = false
		}
	}
}