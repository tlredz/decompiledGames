local ShopItems = {
	remoteConfigDirectory = "Shop/Items",
	isPublic = true,
	isLoaded = false,
	cache = nil
}

function ShopItems.GetConfig()
	while not ShopItems.isLoaded do
		task.wait()
	end

	return ShopItems.cache
end

return ShopItems