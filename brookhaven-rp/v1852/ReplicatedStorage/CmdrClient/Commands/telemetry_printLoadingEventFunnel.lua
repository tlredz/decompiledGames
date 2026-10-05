return {
	Name = "telemetry_printLoadingEventFunnel",
	Aliases = {},
	Description = "Sends the loading event funnel data of a player to the client.",
	Group = "Group",
	Args = {
		{
			Type = "player",
			Name = "player",
			Description = "The player to print the loading event funnel for."
		}
	}
}