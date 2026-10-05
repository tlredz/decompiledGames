return {
	Name = "giveeventitems",
	Aliases = { "geitems" },
	Description = "Give one of every item of an event to a player (default: yourself).",
	Group = "Debug",
	Args = {
		{
			Type = "itemEvent",
			Name = "event",
			Description = "Item EventKey (e.g. Halloween2026)."
		},
		{
			Type = "itemTier",
			Name = "tier",
			Description = "Item tier (0-5).",
			Optional = true,
			Default = 0
		},
		{
			Type = "player",
			Name = "player",
			Description = "Target player (default: you).",
			Optional = true
		},
		{
			Type = "boolean",
			Name = "includeLimited",
			Description = "Also give limited items. Each one consumes a real global serial.",
			Optional = true,
			Default = false
		}
	}
}