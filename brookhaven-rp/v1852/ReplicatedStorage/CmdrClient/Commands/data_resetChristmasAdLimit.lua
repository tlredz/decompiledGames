return {
	Name = "data_resetChristmasAdLimit",
	Aliases = {},
	Description = "Reset the ad limit for a player",
	Group = "Data",
	Args = {
		{
			Type = "player",
			Name = "player",
			Description = "Player that will have their tickets updated",
			Optional = false
		}
	}
}