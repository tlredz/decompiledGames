return {
	Name = "telemetry_printSessionSummary",
	Aliases = {},
	Description = "Prints the session summary for the player",
	Group = "Telemetry",
	Args = {
		{
			Type = "player",
			Name = "player",
			Description = "The player to print the session summary for"
		}
	}
}