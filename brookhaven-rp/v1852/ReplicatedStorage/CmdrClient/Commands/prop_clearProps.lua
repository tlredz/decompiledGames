return {
	Name = "prop_clearProps",
	Aliases = {},
	Description = "Clears all props from the workspace",
	Group = "Prop",
	Args = {
		{
			Type = "boolean",
			Name = "deleteOwnedProps",
			Description = "If false, dont delete props owned by the player",
			Default = true,
			Optional = true
		}
	}
}