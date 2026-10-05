local AvatarsConfig = {
	remoteConfigDirectory = "AvatarEditor/Avatars",
	isPublic = true,
	isLoaded = false,
	cache = nil,
	middlewares = {
		setupData = function(items)
			local result = {}

			for _, item in items do
				result[item.Name] = item
			end

			return result
		end
	}
}

function AvatarsConfig.getConfig()
	while not AvatarsConfig.isLoaded do
		task.wait()
	end

	return AvatarsConfig.cache
end

return AvatarsConfig