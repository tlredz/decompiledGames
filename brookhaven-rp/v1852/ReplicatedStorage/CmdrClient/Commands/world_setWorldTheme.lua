return {
	Name = "world_setServerTheme",
	Aliases = {},
	Description = "Private server owners can set the server-sided theme to a specific theme",
	Group = "World",
	Args = {
		{
			Type = "string",
			Name = "ThemeId",
			Description = [[
the id of the theme to set the server-sided theme to, this should match with the name of the theme in ServerStorage.Themes - usually along the lines of "Theme001"!

Provide "nil" to clear the server-sided theme.]]
		}
	}
}