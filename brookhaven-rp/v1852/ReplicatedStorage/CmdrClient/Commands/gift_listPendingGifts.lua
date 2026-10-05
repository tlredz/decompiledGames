return {
	Name = "gift_listPendingGifts",
	Aliases = {},
	Description = "Lists gifts currently in progess",
	Group = "Product",
	Args = {
		{
			Type = "positiveInteger",
			Name = "count",
			Description = "maximum number of gifts to list",
			Default = 10
		},
		{
			Type = "boolean",
			Name = "delete",
			Description = "true to delete all listed gits",
			Default = false
		}
	}
}