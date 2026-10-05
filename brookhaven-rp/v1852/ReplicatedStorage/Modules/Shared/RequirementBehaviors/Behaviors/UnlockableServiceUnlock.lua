local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
require(ReplicatedStorage.Modules.Shared.LiveOps.LiveOpsUtil)
local UnlockableServiceUnlock = {}

function UnlockableServiceUnlock.PassesRequirementServer(p, _, p2: string)
	local UnlockablesService = require(ServerScriptService.Modules.PlayerData.UnlockablesService)

	if UnlockablesService.IsFeatureUnlocked(p, p2) then
		return true
	end

	return false
end

function UnlockableServiceUnlock.PassesRequirementClient(_, _, p: string)
	local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)

	if UnlockableController.IsFeatureUnlocked(p) then
		return true
	end

	return false
end

function UnlockableServiceUnlock.DeniedMessage(_, _: string)
	return "You are not allowed to use this tool."
end

function UnlockableServiceUnlock.IsVisible(p: string)
	local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
	return UnlockableController.IsFeatureUnlocked(p, nil)
end

return UnlockableServiceUnlock