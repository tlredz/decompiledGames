return {
	Name = "cc_teleport",
	Aliases = { "cc_tp" },
	Description = "Teleports player(s) to another player",
	Group = "Content Creators",
	Args = {
		{
			Type = "players",
			Name = "playersToTeleport",
			Description = "Players to teleport",
			Optional = false
		},
		{
			Type = "player",
			Name = "targetPlayer",
			Description = "Player to teleport to",
			Optional = false
		},
		{
			Type = "number",
			Name = "delay",
			Description = "Optional delay in seconds before teleporting",
			Optional = true
		}
	}
}