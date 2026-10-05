return {
	Name = "addBanner",
	Aliases = {},
	Description = "Adds an additional banner for a set amount of time.",
	Group = "StudioDeveloper",
	Args = {
		{
			Type = "banner",
			Name = "banner_name",
			Description = "The name of the banner to add (use underscores, no spaces)."
		},
		{
			Type = "number",
			Name = "days",
			Description = "Number of days the banner should appear."
		}
	}
}