return {
	Name = "removeWaypoint",
	Aliases = {
		"rwp",
		"rmwp",
		"delwp",
		"removewp",
		"deletewp",
		"waypointremove"
	},
	Description = "Removes a waypoint.",
	Group = "Utility",
	Args = {
		{
			Type = "waypoint",
			Name = "Waypoint Name",
			Description = "The name of the waypoint to remove."
		}
	}
}