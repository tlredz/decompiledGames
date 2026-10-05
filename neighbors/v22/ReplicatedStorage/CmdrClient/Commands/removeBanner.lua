return {
	Name = "removeBanner",
	Aliases = {},
	Description = "Removes any additional banners set manually.",
	Group = "StudioDeveloper",
	Args = {
		{
			Type = "banner",
			Name = "banner_name",
			Description = "The name of the banner to remove (use underscores, no spaces)."
		}
	}
}