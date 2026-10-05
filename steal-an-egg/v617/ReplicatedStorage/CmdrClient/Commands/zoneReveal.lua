return {
	Name = "zoneReveal",
	Description = "Reveals or hides the Cherry Blossom zone on this server (open by default, the dragon event hides it).",
	Aliases = { "" },
	Group = "Admin",
	Args = {
		{
			Type = "boolean",
			Name = "Revealed",
			Description = "true to reveal, false to hide."
		}
	}
}