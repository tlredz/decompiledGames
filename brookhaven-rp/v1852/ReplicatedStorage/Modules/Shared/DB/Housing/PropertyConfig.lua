local PropertyConfig = {
	remoteConfigDirectory = "Housing/Property",
	isPublic = true,
	isLoaded = false,
	cache = nil
}

function PropertyConfig.GetConfig()
	while not PropertyConfig.isLoaded do
		task.wait()
	end

	return PropertyConfig.cache
end

return PropertyConfig