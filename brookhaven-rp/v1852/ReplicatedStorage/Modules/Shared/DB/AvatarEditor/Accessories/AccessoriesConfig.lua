local AccessoriesConfig = {
	remoteConfigDirectory = "AvatarEditor/Accessories",
	isPublic = true,
	isLoaded = false,
	cache = nil
}

function AccessoriesConfig.getConfig()
	while not AccessoriesConfig.isLoaded do
		task.wait()
	end

	return AccessoriesConfig.cache
end

return AccessoriesConfig