return {
	Name = "cc_setSkybox",
	Aliases = {},
	Description = "Set the server skybox from a named preset (see ContentCreatorsSkyboxes)",
	Group = "Content Creators",
	Args = {
		{
			Type = "contentCreatorsSkyboxName",
			Name = "skyboxName",
			Description = "Named skybox preset",
			Optional = false
		}
	}
}