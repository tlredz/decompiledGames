local CharacterBodyConfig = {
	remoteConfigDirectory = "AvatarEditor/CharacterBody",
	isPublic = true,
	isLoaded = false,
	cache = nil
}

function CharacterBodyConfig.getConfig()
	while not CharacterBodyConfig.isLoaded do
		task.wait()
	end

	return CharacterBodyConfig.cache
end

return CharacterBodyConfig