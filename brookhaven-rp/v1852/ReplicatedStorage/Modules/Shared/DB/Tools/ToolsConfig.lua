local ToolsConfig = {
	remoteConfigDirectory = "Tools/Config",
	isPublic = true,
	isLoaded = false,
	cache = nil
}

function ToolsConfig.GetConfig()
	while not ToolsConfig.isLoaded do
		task.wait()
	end

	return ToolsConfig.cache
end

return ToolsConfig