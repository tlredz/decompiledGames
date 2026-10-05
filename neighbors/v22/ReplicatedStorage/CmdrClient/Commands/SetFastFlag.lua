return {
	Name = "setfastflag",
	Aliases = { "setfastflag", "fastflag", "flag" },
	Description = "sets a fast flag",
	Group = "Manager",
	Args = {
		{
			Type = "fastflag",
			Name = "key",
			Description = "the type of fast flag"
		},
		{
			Type = "string",
			Name = "value",
			Description = "the new value of the fast flag"
		}
	}
}