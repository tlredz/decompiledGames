return {
	Name = "gamepass",
	Description = "Gifts a gamepass to the player",
	Group = { "Owner", "Developer", "HeadMod" },
	Args = {
		{
			Type = "username",
			Name = "Username"
		},
		{
			Type = "number",
			Name = "ID of gamepass"
		}
	}
}