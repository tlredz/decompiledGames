return {
	Name = "replica_youngRoddoName",
	Aliases = {},
	Description = "Toggles Young Roddo's name above replicated players, piggybacked over replica messaging",
	Group = "Debug",
	Args = {
		{
			Type = "boolean",
			Name = "enabled",
			Description = "whether to label replicas with Young Roddo's name"
		}
	}
}