local AnimationsConfig = {
	remoteConfigDirectory = "AvatarEditor/Animations",
	isPublic = true,
	isLoaded = false,
	cache = nil
}

function AnimationsConfig.getConfig()
	while not AnimationsConfig.isLoaded do
		task.wait()
	end

	return AnimationsConfig.cache
end

return AnimationsConfig