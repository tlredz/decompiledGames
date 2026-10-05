return {
	Name = "volcanocutscene",
	Aliases = { "vcutscene" },
	Description = "Plays the volcano reveal cutscene on THIS server - for everyone, or only the players you list. The volcano has to be revealed first.",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "players",
			Name = "players",
			Description = "Who sees it. Leave it off for everyone on this server.",
			Optional = true
		}
	}
}