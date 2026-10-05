return {
	Name = "creatorPreview",
	Description = "Shows the creator panel as a content creator sees it, without admin cards.",
	Group = "Admin",
	Args = {
		{
			Type = "players",
			Name = "Player",
			Description = "The players to change."
		},
		{
			Type = "boolean",
			Name = "Preview",
			Description = "true to drop panel admin access, false to restore it."
		}
	}
}