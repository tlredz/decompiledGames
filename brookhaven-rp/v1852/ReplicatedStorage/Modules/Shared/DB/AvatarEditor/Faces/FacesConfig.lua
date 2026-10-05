local FacesConfig = {
	remoteConfigDirectory = "AvatarEditor/Faces",
	isPublic = true,
	isLoaded = false,
	cache = nil
}

function FacesConfig.getConfig()
	while not FacesConfig.isLoaded do
		task.wait()
	end

	return FacesConfig.cache
end

return FacesConfig