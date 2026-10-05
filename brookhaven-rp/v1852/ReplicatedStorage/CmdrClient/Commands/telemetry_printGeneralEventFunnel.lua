return {
	Name = "telemetry_printGeneralEventFunnel",
	Aliases = {},
	Description = "Sends the general event funnel data of a player to the client.",
	Group = "Group",
	Args = {
		{
			Type = "player",
			Name = "player",
			Description = "The player to print the general event funnel for."
		}
	}
}