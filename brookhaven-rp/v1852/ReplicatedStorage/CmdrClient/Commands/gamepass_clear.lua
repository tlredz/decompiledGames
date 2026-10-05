return {
	Name = "gamepass_clear",
	Aliases = {},
	Description = "Clear owned gamepasses for a player",
	Group = "Product",
	Args = {
		{
			Type = "playerId",
			Name = "player",
			Description = "target player"
		}
	}
}