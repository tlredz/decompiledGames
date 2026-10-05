return {
	Name = "customMoveset",
	Description = "exports/imports current moveset",
	Group = {
		"Owner",
		"Developer",
		"HeadMod",
		"CustomMoveset"
	},
	Args = {
		{
			Type = "string",
			Name = "moveset data",
			Description = "Paste exported data here (must be wrapped in quotes \"\")",
			Optional = true
		},
		{
			Type = "player",
			Name = "player to load for",
			Description = "Head Mod+",
			Optional = true
		},
		{
			Type = "boolean",
			Name = "save when rejoining",
			Description = "loads the moveset when you rejoin (only works if you load on self)",
			Optional = true
		}
	}
}