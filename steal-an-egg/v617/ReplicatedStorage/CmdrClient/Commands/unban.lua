return {
	Name = "unban",
	Description = "Lift a ban placed with the ban command or the creator dashboard.",
	Group = "Admin",
	Args = {
		{
			Type = "banTargets",
			Name = "Players",
			Description = "Who to unban: a username, or #userid."
		}
	}
}