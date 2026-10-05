return {
	Name = "player_ban",
	Aliases = {},
	Description = "Bans a player from the game",
	Group = "Player",
	Args = {
		{
			Type = "string",
			Name = "player",
			Description = "Player that will be banned"
		},
		{
			Type = "number",
			Name = "durationInDays",
			Description = "Duration of the ban in days"
		},
		{
			Type = "string",
			Name = "displayReason",
			Description = "Reason for the ban to display to the player"
		},
		{
			Type = "string",
			Name = "privateReason",
			Description = "Private reason for the ban (not shown to the player)"
		},
		{
			Type = "boolean",
			Name = "IPBan",
			Description = "Y = IP Ban User (All Alt Accounts) N = Ban only this specific User",
			Default = false,
			Optional = true
		}
	}
}