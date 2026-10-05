local PlayerRewardsClient = {}
local localPlayer = game.Players.LocalPlayer
require(localPlayer.PlayerScripts.Client)

function UpdateRewardsFrame()
	localPlayer:WaitForChild("RewardsInventory")
end

function RewardTypeFolderAdded(instance)
	instance.ChildAdded:Connect(function(child)
		child.AttributeChanged:Connect(function()
			UpdateRewardsFrame()
		end)
		UpdateRewardsFrame()
	end)
	instance.ChildRemoved:Connect(function()
		UpdateRewardsFrame()
	end)
	UpdateRewardsFrame()
end

function TrackRewardsFolder()
	local rewardsInventory = localPlayer:WaitForChild("RewardsInventory")
	rewardsInventory.ChildAdded:Connect(function(child)
		RewardTypeFolderAdded(child)
	end)

	for _, _ in pairs(rewardsInventory:GetChildren()) do
		RewardTypeFolderAdded(rewardsInventory)
	end

	UpdateRewardsFrame()
end

function PlayerRewardsClient.Init()
	task.spawn(function()
		TrackRewardsFolder()
	end)
end

return PlayerRewardsClient