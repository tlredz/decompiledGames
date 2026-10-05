return {
	Name = "notify",
	Aliases = { "" },
	Description = "Notifies the current Server.",
	Group = "StudioDeveloper",
	Args = {
		{
			Type = "string",
			Name = "text",
			Description = "Text that will show to other players"
		}
	}
}