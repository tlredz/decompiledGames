return {
	Name = "mod_removeOutfitCode",
	Aliases = {},
	Description = "Remove an outfit code from the backend",
	Group = "Moderation",
	Args = {
		{
			Type = "string",
			Name = "code",
			Description = "The code to remove (format: BH-AE-<X>)"
		}
	}
}