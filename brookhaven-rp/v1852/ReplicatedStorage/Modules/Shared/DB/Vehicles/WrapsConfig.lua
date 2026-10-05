local WrapsConfig = {
	remoteConfigDirectory = "Vehicles/Wraps",
	isPublic = true,
	isLoaded = false,
	cache = nil,
	middlewares = {
		setupData = function(items)
			local result = {}

			for k, item in items do
				result[k] = {
					Name = k,
					DisplayName = item.DisplayName,
					LayoutOrder = item.LayoutOrder,
					DecalId = item.DecalId,
					Color = Color3.fromHex(item.Color)
				}
			end

			return result
		end
	}
}

function WrapsConfig.GetConfig()
	while not WrapsConfig.isLoaded do
		task.wait()
	end

	return WrapsConfig.cache
end

return WrapsConfig