local ShowcasedContentConfig = {
	remoteConfigDirectory = "AvatarEditor/ShowcasedContent",
	isPublic = true,
	isLoaded = false,
	cache = nil
}

function ShowcasedContentConfig.getConfig()
	while not ShowcasedContentConfig.isLoaded do
		task.wait()
	end

	return ShowcasedContentConfig.cache
end

return ShowcasedContentConfig