local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Modules.Shared.LiveOps.LiveOpsUtil)
local EasterEventEggLauncherCompleted = {}

function EasterEventEggLauncherCompleted.PassesRequirementServer(p, p2, p3: string)
	if p2.Data.__replicated.LiveOpsEventData.Easter2025 and p2.Data.__replicated.LiveOpsEventData.Easter2025.DifficultiesCompleted[p3] then
		return true
	end

	local ServerScriptService = game:GetService("ServerScriptService")
	local UnlockablesService = require(ServerScriptService.Modules.PlayerData.UnlockablesService)
	return (UnlockablesService.IsFeatureUnlocked(p, "EggLauncher"))
end

function EasterEventEggLauncherCompleted.PassesRequirementClient(_, p, p2: string)
	if p.LiveOpsEventData.Easter2025 and p.LiveOpsEventData.Easter2025.DifficultiesCompleted[p2] then
		return true
	end

	local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
	local UnlockableController = require(ReplicatedStorage2.Modules.Client.PlayerData.UnlockableController)
	return (UnlockableController.IsFeatureUnlocked("EggLauncher"))
end

function EasterEventEggLauncherCompleted.DeniedMessage(_, _: string)
	return "You are not allowed to use this tool."
end

EasterEventEggLauncherCompleted.IsVisible = true
return EasterEventEggLauncherCompleted