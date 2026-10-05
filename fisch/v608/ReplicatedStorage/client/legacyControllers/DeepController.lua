local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("UserInputService")
local packages = ReplicatedStorage.packages
local Net = require(packages.Net)
local Signal = require(packages.Signal)
local Trove = require(packages.Trove)
require(packages.ContextActionUtility)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local DeepConfig = require(ReplicatedStorage.shared.modules.DeepConfig)
local localPlayer = game.Players.LocalPlayer
local playerDataReplicator = DataController.PlayerDataReplicator
local components = script:WaitForChild("Components")
local remoteEvent = Net:RemoteEvent("Deep/SectorActivated")
local DeepController = {
	LightModuleEnabled = true,
	SectorChanged = Signal.new(),
	LightModuleChanged = Signal.new(),
	SectorActivated = Signal.new()
}
local v = Trove.new()

function DeepController.IsSectorActive(_, p: string)
	return playerDataReplicator:TryIndex({ "TheDeep", "Sectors", p }) == true
end

function DeepController:ObserveSector(p: string, callback)
	return playerDataReplicator:Observe({ "TheDeep", "Sectors", p }, function(p2)
		callback(p2 == true)
	end)
end

function DeepController.IsCapsuleScanned(_, p: string)
	return playerDataReplicator:TryIndex({ "TheDeep", "DataCapsules", p }) == true
end

function DeepController:HasLightModule()
	local character = localPlayer.Character
	return character ~= nil and character:GetAttribute("LightModuleEnhancer") ~= nil
end

local function setupCharacter(character)
	v:Clean()
	v:Connect(character:GetAttributeChangedSignal("LightModuleEnhancer"), function()
		DeepController.LightModuleChanged:Fire(DeepController:HasLightModule())
	end)
	DeepController.LightModuleChanged:Fire(DeepController:HasLightModule())
end

function DeepController:Start()
	playerDataReplicator:WaitForLoaded()

	for _, sector in DeepConfig.Sectors do
		local v2 = sector
		DeepController:ObserveSector(sector, function(p)
			DeepController.SectorChanged:Fire(v2, p)
		end)
	end

	remoteEvent.OnClientEvent:Connect(function(p: string)
		DeepController.SectorActivated:Fire(p)
	end)
	localPlayer.CharacterAdded:Connect(setupCharacter)

	if localPlayer.Character then
		setupCharacter(localPlayer.Character)
	end

	local function startComponent(moduleScript)
		if not moduleScript:IsA("ModuleScript") then
			return
		end

		local success, result = pcall(require, moduleScript)

		if not success then
			warn((`[DeepService]: {result}`))
		elseif result.Start then
			result:Start()
		end
	end

	for _, child in components:GetChildren() do
		task.spawn(startComponent, child)
	end

	components.ChildAdded:Connect(startComponent)
end

return DeepController