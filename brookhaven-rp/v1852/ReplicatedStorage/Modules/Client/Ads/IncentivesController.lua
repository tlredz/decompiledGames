local IncentivesController = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Modules.Client.Data.ReplicatedDataController)
local IncentivesRewardClaimController = require(ReplicatedStorage.Modules.Client.UI.IncentivesRewardClaimController)
local IntroController = require(ReplicatedStorage.Modules.Client.UI.IntroController)
local Remotes = require(ReplicatedStorage.Packages.Remotes)

function IncentivesController.FrameworkInit() end

function IncentivesController.FrameworkStart()
	IntroController.OnPlayButtonPressed:Connect(function()
		IncentivesController.CheckForPendingRewards()
	end)
end

function IncentivesController.CheckForPendingRewards()
	local v, itemName, rewardIcon, duration = Remotes.invokeServer("ClaimPendingReward")

	if not v then
		return false
	end

	task.spawn(IncentivesRewardClaimController.Show, {
		itemName = itemName,
		rewardIcon = rewardIcon,
		duration = duration
	})
end

return IncentivesController