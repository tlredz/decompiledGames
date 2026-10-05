local EmmitersConfig = {
	remoteConfigDirectory = "AvatarEditor/Emmiters",
	isPublic = true,
	isLoaded = false,
	cache = nil
}

function EmmitersConfig.getConfig()
	while not EmmitersConfig.isLoaded do
		task.wait()
	end

	return EmmitersConfig.cache
end

return EmmitersConfig