return {
	Name = "gift",
	Aliases = { "g" },
	Description = "Gifts a player a product offline.",
	Group = "StudioDeveloper",
	Args = {
		{
			Type = "string",
			Name = "username",
			Description = "The username of the recipient."
		},
		{
			Type = "string",
			Name = "productName",
			Description = "The name of the product. (use underscores instead of space)"
		},
		{
			Type = "number",
			Name = "Amount",
			Description = "The amount of gifts you want to send."
		},
		{
			Type = "string",
			Name = "note",
			Optional = true,
			Description = "The note that comes with the gift."
		}
	}
}