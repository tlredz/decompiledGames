local LegoFireConfig = {
	remoteConfigDirectory = "Gameplay/LegoFire",
	isPublic = true,
	isLoaded = false,
	cache = nil
}

function LegoFireConfig.GetConfig()
	while not LegoFireConfig.isLoaded do
		task.wait()
	end

	return LegoFireConfig.cache
end

return LegoFireConfig