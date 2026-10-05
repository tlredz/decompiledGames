local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
local ServerInfo = require(ReplicatedStorage.ServerInfo)
require(ReplicatedStorage.Controllers.AnalyticsController)
local _ = { "GachaNPC" }
local _ = { "IceDragonGacha", "FireDragonGacha", "ChromaGacha" }
return Observers.observeTagNoAncestry("TimeModelVisibilityAB", function(_)
	if ServerInfo.isTestGame() then
	end

	return nil
end)