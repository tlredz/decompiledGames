return {
	Name = "afkTestGroup",
	Description = "Forces the AFK treadmill A/B test group. Applies on next join or server hop.",
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
			Name = "Group",
			Description = "Control, Variant, or Clear to return to normal enrollment."
		}
	}
}