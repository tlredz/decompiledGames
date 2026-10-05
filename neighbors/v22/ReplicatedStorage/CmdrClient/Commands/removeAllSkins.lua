return {
	Name = "removeallskins",
	Aliases = { "remove-all-skin" },
	Description = "Removes all skins from the specified player",
	Group = "StudioDeveloper",
	Args = {
		{
			Type = "players",
			Name = "players",
			Description = "The players to remove skins from."
		}
	}
}