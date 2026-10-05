local ReplicatedStorage = game:GetService("ReplicatedStorage")
local legacyControllers = ReplicatedStorage.client.legacyControllers
local DataController = require(legacyControllers.DataController)
local packages = ReplicatedStorage:WaitForChild("packages")
local Net = require(packages:WaitForChild("Net"))
local module = require("./Shared")
local v = {
	ObserveReplicatedDataKey = function(p, p2)
		return DataController.PlayerDataReplicator:Observe({ p }, p2)
	end,
	TeleportPlayer = require("@self/TeleportPlayerClient"),
	ProximityPrompt = module.ProximityPrompt,
	IsTradePlaza = module.IsTradePlaza,
	GetPlayerZone = module.GetPlayerZone,
	GetZoneName = module.GetZoneName,
	GetZonesAt = module.GetZonesAt,
	GetZoneMeta = module.GetZoneMeta,
	ItemDisplay = module.ItemDisplay,
	GradientRichText = module.GradientRichText,
	GetWeightClass = module.GetWeightClass,
	CheckWeightClass = module.CheckWeightClass,
	QuickFishAttributes = module.QuickFishAttributes,
	QuickFishName = module.QuickFishName,
	FindQuestFish = module.FindQuestFish,
	GetItemIcon = module.GetItemIcon,
	PreloadAsync = module.PreloadAsync,
	PreloadSpawn = module.PreloadSpawn,
	CanPurchase = module.CanPurchase
}
task.spawn(function()
	Net:RemoteEvent("RequestTeleport", 1e999).OnClientEvent:Connect(v.TeleportPlayer)
end)
return table.freeze(v)