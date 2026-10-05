return {
	Name = "lightDarkReveal",
	Description = "Lifts or reseals the Light & Dark zone's veil EVERYWHERE (persisted live event flag).",
	Group = "Admin",
	Args = {
		{
			Type = "string",
			Name = "Action",
			Description = "'reveal' to lift the veil, 'seal' to reset it, 'status' to look."
		},
		{
			Type = "string",
			Name = "Winner",
			Description = "Light or Dark; omitted on reveal = read the global event score.",
			Optional = true
		}
	}
}