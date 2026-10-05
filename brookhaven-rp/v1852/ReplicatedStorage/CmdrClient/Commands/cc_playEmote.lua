return {
	Name = "cc_playEmote",
	Aliases = {},
	Description = "Play an emote for a player",
	Group = "Content Creators",
	Args = {
		{
			Type = "players",
			Name = "players",
			Description = "Players that will play the emote",
			Optional = false
		},
		{
			Type = "emoteId",
			Name = "emoteName",
			Description = "Name of the emote to play",
			Optional = false
		},
		{
			Type = "number",
			Name = "delay",
			Description = "Optional delay in seconds before playing the emote",
			Optional = true
		}
	}
}