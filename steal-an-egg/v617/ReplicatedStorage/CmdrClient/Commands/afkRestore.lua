return {
	Name = "afkRestore",
	Description = "Runs the AFK treadmill restore flow for testing. respawn = respawn in place then restore (works in Studio). hop = real same-place AfkRestore teleport, restore runs on arrival for Variant players.",
	Aliases = { "" },
	Group = "Admin",
	Args = {
		{
			Type = "players",
			Name = "Player",
			Description = "The players to put back on their treadmill."
		},
		{
			Type = "string",
			Name = "Mode",
			Description = "respawn or hop.",
			Optional = true,
			Default = "respawn"
		}
	}
}