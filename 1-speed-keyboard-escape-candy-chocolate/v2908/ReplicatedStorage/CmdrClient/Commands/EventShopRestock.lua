return {
	Name = "eventshoprestock",
	Aliases = { "esrestock" },
	Description = "Restock a rotating event shop now, on every server.",
	Group = "Debug",
	Args = {
		{
			Type = "eventShop",
			Name = "shop",
			Description = "Event shop id."
		}
	}
}