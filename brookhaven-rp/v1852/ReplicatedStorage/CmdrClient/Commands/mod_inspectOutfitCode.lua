return {
	Name = "mod_inspectOutfitCode",
	Aliases = {},
	Description = "\"Inspects\" an outfit code stored on the backend for moderation purposes, equipping it to the player and showing details about the code's origin.",
	Group = "Moderation",
	Args = {
		{
			Type = "string",
			Name = "code",
			Description = "The code to inspect (format: BH-AE-<X>)"
		},
		{
			Type = "boolean",
			Name = "verbose",
			Description = "Whether to show verbose output of the code's details or not, if this is true then a JSON dump of the entire code's appearance data will be outputted alongisde usual inspection details.",
			Optional = true,
			Default = false
		}
	}
}