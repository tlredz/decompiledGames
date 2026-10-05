local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GeneralConfig = require(ReplicatedStorage.Config.GeneralConfig)
local RaceConfig = require(ReplicatedStorage:WaitForChild("FeatureConfigs"):WaitForChild("RaceConfig"))

if not table.find(RaceConfig.RACE_WORLDS, GeneralConfig:GetWorldStatus()) then
	return
end

require(script.RaceController)
require(script.ChronoUISystem)
require(script.LeaderboardUISystem)