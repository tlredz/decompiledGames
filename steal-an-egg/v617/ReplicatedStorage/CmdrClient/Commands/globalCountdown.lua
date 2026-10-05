return {
	Name = "globalCountdown",
	Description = "Start the Countdown event in all servers, with an optional title above the timer",
	Group = "Moderator",
	Args = {
		{
			Type = "number",
			Name = "Duration",
			Description = "Seconds to count down"
		},
		{
			Type = "string",
			Name = "Title",
			Description = "Shown above the timer (defaults to SOMETHING BIG COMING SOON!)",
			Optional = true
		}
	}
}