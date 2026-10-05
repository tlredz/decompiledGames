return {
	Name = "createPrivateServer",
	Description = "Reserves a new server for this place and teleports players to it.",
	Group = "Admin",
	Args = {
		{
			Type = "players",
			Name = "Players",
			Description = "The players to send to the reserved server."
		}
	}
}