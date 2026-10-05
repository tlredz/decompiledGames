return {
	Name = script.Name,
	Description = "Show or hide the lights connections.",
	Group = "Housing",
	Args = {
		{
			Type = "boolean",
			Name = "show",
			Default = true,
			Description = "Whether to show (true) or hide (false) the lights connections"
		}
	}
}