local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
require(ReplicatedStorage.Modules.Shared.LiveOps.LiveOpsUtil)
local Summer2025VIP = {}

function Summer2025VIP.PassesRequirementServer(p, _, p2: string)
	local UnlockablesService = require(ServerScriptService.Modules.PlayerData.UnlockablesService)
	return UnlockablesService.IsFeatureUnlocked(p, p2, nil)
end

function Summer2025VIP.PassesRequirementClient(_, _, p: string)
	local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
	return UnlockableController.IsFeatureUnlocked(p, nil)
end

function Summer2025VIP.DeniedMessage(_, _: string)
	return "Unlock at the Summer Carnival by having the VIP gamepass!"
end

function Summer2025VIP.IsVisible(p: string)
	local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
	return UnlockableController.IsFeatureUnlocked(p, nil)
end

return Summer2025VIP