local VideoPlayerConfig = {
	remoteConfigDirectory = "VideoPlayer/Config",
	isPublic = true,
	isLoaded = false,
	cache = nil
}

function VideoPlayerConfig.GetConfig()
	while not VideoPlayerConfig.isLoaded do
		task.wait()
	end

	return VideoPlayerConfig.cache
end

function VideoPlayerConfig.GetVideoId(p: string)
	return VideoPlayerConfig.GetConfig()[p]
end

return VideoPlayerConfig