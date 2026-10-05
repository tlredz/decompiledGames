return {
	Name = "telemetry_printTimeSpentBreakdownSummary",
	Aliases = {},
	Description = "Prints the time spent breakdown summary for the player",
	Group = "Telemetry",
	Args = {
		{
			Type = "player",
			Name = "player",
			Description = "The player to print the time spent breakdown summary for"
		}
	}
}