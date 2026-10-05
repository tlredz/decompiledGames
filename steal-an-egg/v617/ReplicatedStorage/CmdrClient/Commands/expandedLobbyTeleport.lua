return {
	Name = "expandedLobbyTeleport",
	Description = "Teleports players into a reserved server locked to an ExpandedLobby group.",
	Aliases = {},
	Group = "Admin",
	Args = {
		{
			Type = "string",
			Name = "Group",
			Description = "Control or Variant."
		},
		{
			Type = "players",
			Name = "Players",
			Description = "The players to teleport. Defaults to you.",
			Optional = true
		}
	}
}