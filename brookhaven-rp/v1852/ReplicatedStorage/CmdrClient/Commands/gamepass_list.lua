return {
	Name = "gamepass_list",
	Aliases = {},
	Description = "List owned gamepasses for a player (including gifts)",
	Group = "Product",
	Args = {
		{
			Type = "playerId",
			Name = "player",
			Description = "target player"
		}
	}
}