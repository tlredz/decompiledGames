local LiveOpsConfig = {
	remoteConfigDirectory = "LiveOps",
	isPublic = true,
	isLoaded = false,
	cache = nil
}

function LiveOpsConfig.GetConfig()
	while not LiveOpsConfig.isLoaded do
		task.wait()
	end

	return LiveOpsConfig.cache
end

return LiveOpsConfig