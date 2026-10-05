return {
	Name = "globalAdminTreadmill",
	Description = "Spawns the Admin Treadmill in the base of all servers.",
	Aliases = { "" },
	Group = "Admin",
	Args = {
		{
			Type = "number",
			Name = "Multiplier",
			Description = "The multiplier to apply (1 - 100)."
		},
		{
			Type = "integer",
			Name = "Duration",
			Description = "The duration in seconds."
		}
	}
}