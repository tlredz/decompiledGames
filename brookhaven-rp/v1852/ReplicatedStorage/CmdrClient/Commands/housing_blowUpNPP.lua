return {
	Name = "housing_blowUpNPP",
	Description = "Blow up any and all Nuclear Power Plants in-game currently.",
	Group = "Housing",
	Args = {
		{
			Name = "external",
			Type = "boolean",
			Description = "Whether to blow up the NPP externally or not.",
			Optional = true,
			Default = false
		}
	}
}