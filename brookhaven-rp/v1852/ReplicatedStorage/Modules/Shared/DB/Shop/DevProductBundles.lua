local DevProductBundles = {
	remoteConfigDirectory = "Shop/DevProductBundles",
	isPublic = true,
	isLoaded = false,
	cache = nil
}

function DevProductBundles.GetConfig()
	while not DevProductBundles.isLoaded do
		task.wait()
	end

	return DevProductBundles.cache
end

return DevProductBundles