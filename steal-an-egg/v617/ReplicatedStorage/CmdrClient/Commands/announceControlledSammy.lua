return {
	Name = "announceControlledSammy",
	Description = "Shows a mind controlled Sammy announcement to your server.",
	Aliases = { "" },
	Group = "Admin",
	Args = {
		{
			Type = "string",
			Name = "Text",
			Description = "The announcement Sammy should say."
		}
	}
}