local SkinTonesConfig = {
	remoteConfigDirectory = "AvatarEditor/SkinTones",
	isPublic = true,
	isLoaded = false,
	cache = nil
}

function SkinTonesConfig.getConfig()
	while not SkinTonesConfig.isLoaded do
		task.wait()
	end

	return SkinTonesConfig.cache
end

return SkinTonesConfig