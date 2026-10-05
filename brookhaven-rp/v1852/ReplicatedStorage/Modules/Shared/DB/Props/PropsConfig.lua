local PropsConfig = {
	remoteConfigDirectory = "Props/Categories",
	isPublic = true,
	isLoaded = false,
	cache = nil
}

function PropsConfig.GetCategoriesConfig()
	while not PropsConfig.isLoaded do
		task.wait()
	end

	return PropsConfig.cache
end

return PropsConfig