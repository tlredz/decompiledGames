local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
game:GetService("RunService")

while not workspace:GetAttribute("ClientModulesLoaded") do
	workspace:GetAttributeChangedSignal("ClientModulesLoaded"):Wait()
end

require(ReplicatedStorage.ServerInfo)

for _, layerCollector in CollectionService:GetTagged("CLOSE_ON_PLAY_TEST") do
	if layerCollector:IsA("LayerCollector") then
		layerCollector.Enabled = false
	else
		warn(layerCollector:GetFullName(), "is not a ScreenGui")
	end
end

CollectionService:GetInstanceAddedSignal("CLOSE_ON_PLAY_TEST"):Connect(function(layerCollector)
	if layerCollector:IsA("LayerCollector") then
		layerCollector.Enabled = false
	else
		warn(layerCollector:GetFullName(), "is not a ScreenGui")
	end
end)