return {
	Name = "telemetry_printJobTimeSummary",
	Aliases = {},
	Description = "Prints the job time summary for the player",
	Group = "Telemetry",
	Args = {
		{
			Type = "player",
			Name = "player",
			Description = "The player to print the job time summary for"
		}
	}
}