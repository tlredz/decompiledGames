return {
	Name = "gift_unsafe",
	Aliases = {},
	Description = "Unsafe mode forces all gifts on this server to succeed by disabling safety checks for leases and pending gifts. Do not use this in production.",
	Group = "Product",
	Args = {
		{
			Type = "boolean",
			Name = "unsafe",
			Description = "true to enable unsafe mode"
		}
	}
}