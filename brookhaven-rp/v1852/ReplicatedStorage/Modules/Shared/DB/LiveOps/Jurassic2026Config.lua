local Jurassic2026Config = {
	remoteConfigDirectory = "LiveOpsConfig/Jurassic2026Config",
	isPublic = true,
	isLoaded = false,
	cache = nil
}

function Jurassic2026Config.GetConfig()
	while not Jurassic2026Config.isLoaded do
		task.wait()
	end

	return Jurassic2026Config.cache
end

return Jurassic2026Config