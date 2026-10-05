return {
	Name = script.Name,
	Aliases = {},
	Description = "Copy a player's avatar to the current player, optionally include the outfit slots",
	Group = "AvatarEditor",
	Args = {
		{
			Type = "number",
			Name = "playerId",
			Description = "The player to copy the avatar from"
		},
		{
			Type = "boolean",
			Name = "includeOutfitSlots",
			Description = "Whether to include the outfit slots",
			Optional = true,
			Default = false
		}
	}
}