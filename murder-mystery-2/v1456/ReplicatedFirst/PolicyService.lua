local PolicyService = game:GetService("PolicyService")
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local v = game.GameId == 119460199
local localPlayer = Players.LocalPlayer
local success, result = pcall(function()
	return PolicyService:GetPolicyInfoForPlayerAsync(localPlayer)
end)

if not success then
	warn("PolicyService error: " .. result)
elseif result.ArePaidRandomItemsRestricted then
	warn("Player cannot interact with paid random item generators")
	ReplicatedFirst:SetAttribute("CratesRestricted", true)
elseif v then
	return
end