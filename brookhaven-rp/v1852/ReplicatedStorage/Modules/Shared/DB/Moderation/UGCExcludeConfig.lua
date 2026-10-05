local UGCExcludeConfig = {
	remoteConfigDirectory = "Moderation/UGCExclude",
	isPublic = true,
	isLoaded = false,
	cache = nil
}

function UGCExcludeConfig.GetConfig()
	while not UGCExcludeConfig.isLoaded do
		task.wait()
	end

	return UGCExcludeConfig.cache
end

return UGCExcludeConfig