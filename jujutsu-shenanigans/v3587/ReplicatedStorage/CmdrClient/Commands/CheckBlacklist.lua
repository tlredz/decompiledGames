return {
	Name = "checkblacklist",
	Description = "Check if an ID is blacklisted anywhere",
	Group = { "Owner", "Developer", "HeadMod" },
	Args = {
		{
			Type = "number",
			Name = "ID"
		}
	}
}