return {
	Name = "waypointTeleport",
	Aliases = {
		"wp",
		"tpwp",
		"towp",
		"waypointtp",
		"teleporttowaypoint"
	},
	Description = "Teleports to a Waypoint.",
	Group = "Utility",
	Args = {
		{
			Type = "waypoint",
			Name = "Waypoint Name",
			Description = "The name of the waypoint to teleport to."
		},
		{
			Type = "players",
			Name = "player",
			Description = "The players to teleport(will teleport you if not specified).",
			Optional = true
		}
	}
}