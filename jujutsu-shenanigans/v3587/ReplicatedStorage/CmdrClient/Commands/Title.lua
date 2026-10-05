return {
	Name = "title",
	Description = "Adds / Remove a title from a player's inventory",
	Group = { "Owner" },
	Args = {
		{
			Type = "username",
			Name = "Username"
		},
		{
			Type = "string",
			Name = "Title"
		},
		{
			Type = "boolean",
			Name = "Clear"
		}
	}
}