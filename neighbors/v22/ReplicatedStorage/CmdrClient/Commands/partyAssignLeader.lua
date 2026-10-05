return {
	Name = "partyassignleader",
	Aliases = { "party-assign-leader" },
	Description = "Assigns a new player as a party's leader",
	Group = "Moderator",
	Args = {
		{
			Type = "player",
			Name = "player",
			Description = "The player to assign"
		}
	}
}