local EventSignupConfig = {
	remoteConfigDirectory = "EventSignup",
	isPublic = true,
	isLoaded = false,
	cache = nil,
	middlewares = {}
}

function EventSignupConfig.GetTargetChangeLog()
	return EventSignupConfig.GetConfig().targetChangeLog
end

function EventSignupConfig.GetConfig()
	while not EventSignupConfig.isLoaded do
		task.wait()
	end

	return EventSignupConfig.cache
end

return EventSignupConfig