return {
	Name = "cashpacks",
	Description = "Cash-pack QA: choose a cohort, change test income, advance a day, or reset.",
	Group = "Admin",
	Args = {
		{
			Type = "string",
			Name = "Context",
			Description = "status, control, a, b, peak, day, reset",
			Default = "status"
		},
		{
			Type = "player",
			Name = "Player",
			Description = "Player to test; defaults to you.",
			Optional = true
		},
		{
			Type = "number",
			Name = "Income",
			Description = "Cash/second for control/a/b/peak, e.g. 7e9. Other contexts omit this.",
			Optional = true
		}
	}
}