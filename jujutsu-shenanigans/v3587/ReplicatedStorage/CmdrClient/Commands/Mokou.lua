return {
	Name = "mokou",
	Description = "Adds a player temporarily to the whitelist",
	Group = { "Owner", "HeadMod" },
	Args = {
		{
			Type = "player",
			Name = "Player"
		},
		{
			Type = "number",
			Name = "Duration (in minutes)"
		}
	}
}