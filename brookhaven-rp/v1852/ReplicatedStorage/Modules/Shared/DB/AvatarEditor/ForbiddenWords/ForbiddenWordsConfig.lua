local ForbiddenWordsConfig = {
	remoteConfigDirectory = "AvatarEditor/ForbiddenWords",
	isPublic = true,
	isLoaded = false,
	cache = nil
}

function ForbiddenWordsConfig.getConfig()
	while not ForbiddenWordsConfig.isLoaded do
		task.wait()
	end

	return ForbiddenWordsConfig.cache
end

return ForbiddenWordsConfig