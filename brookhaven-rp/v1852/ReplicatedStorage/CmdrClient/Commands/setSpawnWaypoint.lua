return {
	Name = "setSpawnWaypoint",
	Aliases = { "setspwp", "sswp", "setswp" },
	Description = "Sets your spawn point to a certain waypoint.",
	Group = "Utility",
	Args = {
		{
			Type = "waypoint",
			Name = "Waypoint Name",
			Description = "The name of the waypoint to assign as your spawn point. If not provided, your spawn waypoint will be cleared.",
			Optional = true
		}
	}
}