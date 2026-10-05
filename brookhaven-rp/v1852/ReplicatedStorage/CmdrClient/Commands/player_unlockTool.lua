return {
	Name = "player_setUnlockToolState",
	Aliases = {},
	Description = "Set the unlock state of a tool for a target player.",
	Group = "Group",
	Args = {
		{
			Type = "player",
			Name = "Target Player",
			Description = "Target player to unlock tool for."
		},
		{
			Type = "unlockableToolId",
			Name = "Tool Id",
			Description = "Id of the tool to unlock."
		},
		{
			Type = "boolean",
			Name = "Unlock State",
			Description = "State to set the tool to."
		}
	}
}