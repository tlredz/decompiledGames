return {
	Name = "kills",
	Description = "Changes the kill amount of a player",
	Group = { "Owner", "HeadMod", "Developer" },
	Args = {
		{
			Type = "username",
			Name = "Username"
		},
		{
			Type = "number",
			Name = "amount"
		}
	}
}