return {
	Name = "replica_youngRoddoInviteSet",
	Aliases = {},
	Description = "Sets the young roddo invite count piggybacked over replica messaging",
	Group = "Debug",
	Args = {
		{
			Type = "number",
			Name = "invites",
			Description = "Invite count to broadcast, clamped to 0-255"
		}
	}
}