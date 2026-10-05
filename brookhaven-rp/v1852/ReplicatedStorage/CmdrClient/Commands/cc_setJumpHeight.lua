return {
	Name = "cc_setJumpHeight",
	Aliases = {},
	Description = "Set the jump height of a player",
	Group = "Content Creators",
	Args = {
		{
			Type = "players",
			Name = "players",
			Description = "Players that will have their jump height set",
			Optional = false
		},
		{
			Type = "number",
			Name = "jumpHeight",
			Description = "The jump height to set",
			Optional = false
		},
		{
			Type = "number",
			Name = "delay",
			Description = "Optional delay in seconds before exploding the player",
			Optional = true
		}
	}
}