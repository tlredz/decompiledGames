local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("Packages")
local GameSdkShared = require(packages.GameSdkShared)
local ClientConfiguration = require(GameSdkShared.Config.ClientConfiguration)
local ExperienceMapping = require(ReplicatedStorage.Modules.Shared.GameSdk.ExperienceMapping)
local GameSdkClientInitializer = {
	Initialized = false
}

function GameSdkClientInitializer.Init()
	if GameSdkClientInitializer.Initialized then
		return
	end

	GameSdkClientInitializer.Initialized = true
	GameSdkShared:Configuration((ClientConfiguration.new():ExperienceMapping(ExperienceMapping):PerformanceSamplePercent(10):PerformanceConnectSamplePercent(0))):Init()
end

return GameSdkClientInitializer