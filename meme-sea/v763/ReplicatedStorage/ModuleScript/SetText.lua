local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local otherEvent = ReplicatedStorage:WaitForChild("OtherEvent")
local rewardScreen = ReplicatedStorage:WaitForChild("RewardScreen")
local miscEvents = otherEvent:WaitForChild("MiscEvents")
local reward = rewardScreen:WaitForChild("Reward")
local makeChat = miscEvents:WaitForChild("MakeChat")
return {
	SetText = function(player, p, p2, p3)
		if RunService:IsClient() then
			makeChat:Fire(p, p2, p3)
		elseif RunService:IsServer() then
			reward:FireClient(player, p, p2, p3)
		end
	end
}