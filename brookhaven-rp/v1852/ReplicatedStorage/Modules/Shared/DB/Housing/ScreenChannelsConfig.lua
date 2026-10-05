local ScreenChannelsConfig = {
	remoteConfigDirectory = "Housing/ScreenChannels",
	isPublic = false,
	isLoaded = false,
	cache = nil
}

function ScreenChannelsConfig.GetConfig()
	while not ScreenChannelsConfig.isLoaded do
		task.wait()
	end

	return ScreenChannelsConfig.cache
end

return ScreenChannelsConfig