return {
	Name = "setWaypoint",
	Aliases = {
		"swp",
		"setwp",
		"newwp",
		"waypointset"
	},
	Description = "Sets a waypoint for later teleportation.",
	Group = "Utility",
	Args = {
		{
			Type = "string",
			Name = "Waypoint Name",
			Description = "The name of the waypoint to set."
		}
	}
}