local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LiveOpsUtil = require(ReplicatedStorage.Modules.Shared.LiveOps.LiveOpsUtil)
local EasterEventDifficultyCompleted = {}

function EasterEventDifficultyCompleted.PassesRequirementServer(_, p, p2: string)
	if p.Data.__replicated.LiveOpsEventData.Easter2025 and p.Data.__replicated.LiveOpsEventData.Easter2025.DifficultiesCompleted[p2] then
		return true
	end

	return false
end

function EasterEventDifficultyCompleted.PassesRequirementClient(_, p, p2: string)
	if p.LiveOpsEventData.Easter2025 and p.LiveOpsEventData.Easter2025.DifficultiesCompleted[p2] then
		return true
	end

	return false
end

function EasterEventDifficultyCompleted.DeniedMessage(_, p: string)
	if LiveOpsUtil.IsEventStarted("Easter2025") then
		return (`Must Complete {p} Egg Hunt.`)
	end

	return "Must be VIP."
end

EasterEventDifficultyCompleted.IsVisible = true
return EasterEventDifficultyCompleted