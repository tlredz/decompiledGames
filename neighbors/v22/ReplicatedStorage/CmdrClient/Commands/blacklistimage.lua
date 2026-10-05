return {
	Name = "blacklistimage",
	Description = "Blacklists an image/decal from profile pictures and comments",
	Group = "Moderator",
	Args = {
		{
			Type = "integer",
			Name = "ID",
			Description = "ID to blacklist"
		}
	}
}