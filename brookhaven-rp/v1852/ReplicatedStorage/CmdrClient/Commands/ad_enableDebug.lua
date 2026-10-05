return {
	Name = "ad_enableDebug",
	Aliases = {},
	Description = "Enables debug ads",
	Group = "Ads",
	Args = {
		{
			Type = "boolean",
			Name = "enable",
			Description = "Whether to enable debug mode or not.",
			Default = true,
			Optional = true
		}
	}
}