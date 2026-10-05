local Minions2026Config = {
	remoteConfigDirectory = "LiveOpsConfig/Minions2026Config",
	isPublic = true,
	isLoaded = false,
	cache = nil
}

function Minions2026Config.GetConfig()
	while not Minions2026Config.isLoaded do
		task.wait()
	end

	return Minions2026Config.cache
end

return Minions2026Config