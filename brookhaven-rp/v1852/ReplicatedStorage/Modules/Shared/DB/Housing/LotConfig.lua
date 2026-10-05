local LotConfig = {
	remoteConfigDirectory = "Housing/Lots",
	isPublic = true,
	isLoaded = false,
	cache = nil
}

function LotConfig.GetConfig()
	while not LotConfig.isLoaded do
		task.wait()
	end

	return LotConfig.cache
end

return LotConfig