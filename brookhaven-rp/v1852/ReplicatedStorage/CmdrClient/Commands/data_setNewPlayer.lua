return {
	Name = "data_setNewPlayer",
	Aliases = {},
	Description = "Set a player as new by setting their session count to 0, install date to now, and kicking them.",
	Group = "Data",
	Args = {
		{
			Type = "player",
			Name = "player",
			Description = "target player"
		},
		{
			Type = "number",
			Name = "timestamp",
			Description = "Install date in milliseconds since epoch",
			Optional = true
		}
	}
}