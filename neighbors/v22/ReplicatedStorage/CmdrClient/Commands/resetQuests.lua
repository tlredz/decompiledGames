return {
	Name = "resetquests",
	Aliases = { "reset-quests" },
	Description = "Resets a player's quests data",
	Group = "CommunityManager",
	Args = {
		{
			Type = "player",
			Name = "player",
			Description = "The player to reset quests of."
		}
	}
}