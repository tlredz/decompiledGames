return {
	Name = "ban",
	Description = "Ban players from the experience with the Roblox ban API.",
	Group = "Admin",
	Args = {
		{
			Type = "banTargets",
			Name = "Players",
			Description = "Who to ban: a username, or #userid. Works on players who are not in the server."
		},
		{
			Type = "banDuration",
			Name = "Duration",
			Description = "Optional. How long the ban lasts: 30m, 12h, 7d, 2w, 1d12h, or perm. Defaults to perm.",
			Default = -1
		},
		{
			Type = "string",
			Name = "Reason",
			Description = "Optional. Shown to the banned player and kept on their ban record. Defaults to Banned by an admin.",
			Default = "Banned by an admin"
		}
	}
}