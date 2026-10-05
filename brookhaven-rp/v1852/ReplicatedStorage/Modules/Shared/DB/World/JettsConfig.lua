local JettsConfig = {
	remoteConfigDirectory = "World/JettsConfig",
	isPublic = true,
	isLoaded = false,
	cache = nil
}

function JettsConfig.GetConfig()
	while not JettsConfig.isLoaded do
		task.wait()
	end

	return JettsConfig.cache
end

return JettsConfig