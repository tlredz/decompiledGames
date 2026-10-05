return {
	Name = "jetts_incrementLocalCounter",
	Aliases = {},
	Description = "Increments the local counter value for Jetts",
	Group = "Jetts",
	Args = {
		{
			Type = "number",
			Name = "value",
			Description = "The value to increment the counter by"
		}
	}
}