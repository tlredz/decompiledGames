return {
	Name = "item",
	Description = "Spawns an item where you're located",
	Group = {
		"Owner",
		"Developer",
		"HeadMod",
		"Mod",
		"Tester",
		"TesterPublic",
		"Contrib"
	},
	Args = {
		{
			Type = "item",
			Name = "Item"
		},
		{
			Type = "boolean",
			Name = "Disable Drop",
			Optional = true
		},
		{
			Type = "boolean",
			Name = "Disable Durability",
			Optional = true
		},
		{
			Type = "number",
			Name = "Despawn Timer",
			Optional = true,
			Default = 10
		},
		{
			Type = "boolean",
			Name = "Auto Equip",
			Optional = true
		}
	}
}