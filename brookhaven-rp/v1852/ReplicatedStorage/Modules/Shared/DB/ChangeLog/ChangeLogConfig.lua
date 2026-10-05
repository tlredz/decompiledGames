local ChangeLogConfig = {
	remoteConfigDirectory = "ChangeLog",
	isPublic = true,
	isLoaded = false,
	cache = nil,
	middlewares = {}
}

function ChangeLogConfig.GetTargetChangeLog()
	return ChangeLogConfig.GetConfig().targetChangeLog
end

function ChangeLogConfig.GetConfig()
	while not ChangeLogConfig.isLoaded do
		task.wait()
	end

	return ChangeLogConfig.cache
end

return ChangeLogConfig