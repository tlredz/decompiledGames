local CollectionService = game:GetService("CollectionService")
local SwimController = require(script.SwimController)
task.wait(2)

for _, v in pairs(CollectionService:GetTagged("Water")) do
	SwimController:AddZone(v)
end

CollectionService:GetInstanceAddedSignal("Water"):Connect(function(p)
	SwimController:AddZone(p)
end)
CollectionService:GetInstanceRemovedSignal("Water"):Connect(function(p)
	SwimController:RemoveZone(p)
end)
SwimController:Start()