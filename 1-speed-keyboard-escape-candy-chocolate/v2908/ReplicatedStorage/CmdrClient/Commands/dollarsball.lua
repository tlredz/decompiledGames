return {
	Name = "dollarsball",
	Aliases = { "db", "dollball" },
	Description = "Fait pleuvoir des orbes ($ CASH $) sur tous les joueurs dans tous les serveurs Monde 4.",
	Group = "Admin",
	Args = {
		{
			Type = "number",
			Name = "amount",
			Description = "Le nombre d'orbes à faire spawn par joueur"
		}
	}
}