return {
	Name = "volcano",
	Aliases = { "vtp" },
	Description = "Teleports players to the rim of the volcano's lava pool, facing the lava.",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "players",
			Name = "players",
			Description = "Who to send. Leave it off to go yourself.",
			Optional = true
		}
	}
}