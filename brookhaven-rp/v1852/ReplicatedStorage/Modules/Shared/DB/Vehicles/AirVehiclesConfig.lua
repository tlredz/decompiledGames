local AirVehiclesConfig = {
	remoteConfigDirectory = "Vehicles/AirVehicles",
	isPublic = true,
	isLoaded = false,
	cache = nil
}

function AirVehiclesConfig.GetConfig()
	while not AirVehiclesConfig.isLoaded do
		task.wait()
	end

	return AirVehiclesConfig.cache
end

function AirVehiclesConfig.IsGamepass(p)
	return p.PassRequired ~= nil
end

return AirVehiclesConfig