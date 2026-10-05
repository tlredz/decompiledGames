return {
	Name = "abTestGroup",
	Description = "Forces a sticky A/B test group for players. Applies on next join or server hop.",
	Aliases = { "" },
	Group = "Admin",
	Args = {
		{
			Type = "players",
			Name = "Player",
			Description = "The players whose group to set."
		},
		{
			Type = "string",
			Name = "Test",
			Description = "The test name, e.g. ExpandedLobbyTest or AfkTreadmillTest."
		},
		{
			Type = "string",
			Name = "Group",
			Description = "The group name to pin, or Clear to return to normal enrollment."
		}
	}
}