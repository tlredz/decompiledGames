return {
	Name = "captureTheEgg",
	Description = "Start Capture The Egg immediately in this server, or queue it behind an active capture. Choose any animal and mutation.",
	Group = "Moderator",
	Args = {
		{
			Type = "assetName",
			Name = "Egg",
			Description = "The animal the event egg hatches into. Defaults to the event's own egg.",
			Optional = true
		},
		{
			Type = "mutation",
			Name = "Mutation",
			Description = "Mutation forced onto the event egg. None when omitted.",
			Optional = true
		}
	}
}