local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local FriendBoost = require(ReplicatedStorage:WaitForChild("FeatureConfigs"):WaitForChild("FriendBoost"))
local FriendBoostUISystem = require(ReplicatedStorage:WaitForChild("UISystems"):WaitForChild("FriendBoostUISystem"))

if not FriendBoost.ENABLED then
	return
end

FriendBoostUISystem:InitLogic()
FriendBoostUISystem:RefreshFriendCount()
ReplicatedStorage:WaitForChild("FriendBoostOverride").OnClientEvent:Connect(function(p)
	if type(p) == "table" and p.percent then
		FriendBoostUISystem:ApplyOverride(p.percent)
	end
end)
Players.PlayerAdded:Connect(function()
	FriendBoostUISystem:RefreshFriendCount()
end)
Players.PlayerRemoving:Connect(function()
	task.defer(function()
		FriendBoostUISystem:RefreshFriendCount()
	end)
end)