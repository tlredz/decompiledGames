return {
	Name = "dollarsmultiplier",
	Aliases = { "dollmul", "dm" },
	Description = "Multiplie les $ CASH $ (Wins) dans tous les serveurs Monde 4.",
	Group = "Admin",
	Args = {
		{
			Type = "number",
			Name = "multiplier",
			Description = "Le multiplicateur à appliquer"
		},
		{
			Type = "number",
			Name = "duration",
			Description = "La durée en minutes"
		}
	}
}