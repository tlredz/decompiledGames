return {
	Name = script.Name,
	Aliases = {},
	Description = "[DEPRECATED - use avatarEditor_becomePlayer instead] Become a player",
	Group = "Utility",
	Args = {
		{
			Type = "number",
			Name = "PlayerId",
			Description = "The player to become"
		},
		{
			Type = "boolean",
			Name = "UseNativeRobloxHumanoid",
			Description = "Whether to use the native Roblox humanoid or our custom logic",
			Default = true
		}
	}
}