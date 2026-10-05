return {
	Name = script.Name,
	Description = "Enables or disables house interior lazy loading (BVH interior streaming) at runtime.",
	Group = "Housing",
	Args = {
		{
			Type = "boolean",
			Name = "enabled",
			Default = true,
			Description = "Whether lazy loading should be enabled (true) or disabled (false)"
		}
	}
}