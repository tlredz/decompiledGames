return {
	Name = "cash",
	Description = "Sets the player's cash to the value specified",
	Group = { "Owner", "Developer", "HeadMod" },
	Args = {
		{
			Type = "player",
			Name = "Player"
		},
		{
			Type = "number",
			Name = "Value"
		}
	}
}