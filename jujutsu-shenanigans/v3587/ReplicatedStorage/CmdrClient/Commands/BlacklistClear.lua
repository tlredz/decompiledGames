return {
	Name = "blacklistclear",
	Description = "Removes an ID to the killsound or billboard blacklist",
	Group = { "Owner", "Developer", "HeadMod" },
	Args = {
		{
			Type = "number",
			Name = "ID"
		}
	}
}