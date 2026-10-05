local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local WickedEvent = {}

function WickedEvent.PassesRequirementServer(p, _, p2: string)
	local UnlockablesService = require(ServerScriptService.Modules.PlayerData.UnlockablesService)
	return UnlockablesService.IsFeatureUnlocked(p, p2, nil)
end

function WickedEvent.PassesRequirementClient(_, _, p: string)
	local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
	return UnlockableController.IsFeatureUnlocked(p, nil)
end

function WickedEvent.DeniedMessage(_, _: string)
	return "Can you find the secret?"
end

function WickedEvent.IsVisible(p: string)
	local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
	return UnlockableController.IsFeatureUnlocked(p, nil)
end

return WickedEvent