return {
	Name = "joincreate",
	Description = [[
Joins a server made with the ingame creator
A player will be forcefully kicked if the server is full]],
	Group = {
		"Owner",
		"Developer",
		"HeadMod",
		"Mod"
	},
	Args = {
		{
			Type = "string",
			Name = "Username"
		}
	}
}