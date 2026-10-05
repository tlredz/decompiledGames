local AdIntegrationsConfig = {
	remoteConfigDirectory = "AdIntegrations/AdIntegrations",
	isPublic = true,
	isLoaded = false,
	cache = nil
}

function AdIntegrationsConfig.GetConfig()
	while not AdIntegrationsConfig.isLoaded do
		task.wait()
	end

	return AdIntegrationsConfig.cache
end

return AdIntegrationsConfig