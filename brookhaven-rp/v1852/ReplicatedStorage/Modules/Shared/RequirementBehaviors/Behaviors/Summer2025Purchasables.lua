local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
require(ReplicatedStorage.Modules.Shared.LiveOps.LiveOpsUtil)
local Summer2025Purchasables = {}

function Summer2025Purchasables.PassesRequirementServer(p, _, p2: string)
	local UnlockablesService = require(ServerScriptService.Modules.PlayerData.UnlockablesService)
	return UnlockablesService.IsFeatureUnlocked(p, p2, nil)
end

function Summer2025Purchasables.PassesRequirementClient(_, _, p: string)
	local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
	return UnlockableController.IsFeatureUnlocked(p, nil)
end

function Summer2025Purchasables.DeniedMessage(_, _: string)
	return "Carnival event already ended! Nice Try!"
end

function Summer2025Purchasables.IsVisible(p: string)
	local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
	return UnlockableController.IsFeatureUnlocked(p, nil)
end

return Summer2025Purchasables