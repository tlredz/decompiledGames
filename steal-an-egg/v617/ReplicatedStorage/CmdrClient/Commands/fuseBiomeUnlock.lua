return {
	Name = "fuseBiomeUnlock",
	Description = "Toggles the Fuse Biome waterfall portal on this server (normally unlocked when the Light vs Darkness event concludes).",
	Aliases = { "" },
	Group = "Admin",
	Args = {
		{
			Type = "string",
			Name = "Action",
			Description = "'on'/'off' to force, 'status' to look; omit to toggle.",
			Optional = true
		}
	}
}