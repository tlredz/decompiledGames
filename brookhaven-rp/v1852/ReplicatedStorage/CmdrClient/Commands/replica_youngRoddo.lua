return {
	Name = "replica_youngRoddo",
	Aliases = {},
	Description = "Handles young roddo flags through piggybacked over replica messaging",
	Group = "Debug",
	Args = {
		{
			Type = "boolean",
			Name = "enabled",
			Description = "whether to enable invites and spawn the dark villain house"
		}
	}
}