local Net = require(game.ReplicatedStorage.Modules.Net)
require(script.Types)
local FX = require(game.ReplicatedStorage.FX)
local remoteFunction = Net:RemoteFunction("BonusMomentsGuide")
local BonusMomentsGuide = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function prepareRewardEffect()
	local success, result = pcall(function()
		FX:Get("BonusMoment")
	end)

	if not success then
		warn((`Failed to prepare bonus moment reward effect: {result}`))
	end
end

task.spawn(prepareRewardEffect)

function BonusMomentsGuide.interactQuestGiver(p: string)
	prepareRewardEffect() -- equivalent call inferred; original call site unknown
	local success, result = pcall(function()
		return remoteFunction:InvokeServer("InteractQuestGiver", p)
	end)

	if success then
		return result
	end

	warn((`Failed to get bonus moment guide dialogue: {result}`))
	return nil
end

function BonusMomentsGuide.getRewardTracker()
	local success, result = pcall(function()
		return remoteFunction:InvokeServer("GetRewardTracker")
	end)

	if success then
		return result
	end

	warn((`Failed to get bonus moment reward tracker: {result}`))
	return nil
end

return BonusMomentsGuide