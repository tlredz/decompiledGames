local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("Players")
local ServerData = require(ReplicatedStorage:WaitForChild("Datas").ServerData)

if not ServerData.IsDuelsServer() then
	return
end

ReplicatedStorage:WaitForChild("Desync"):WaitForChild("UnreliableRemoteEvent").OnClientEvent:Connect(function(player, cFrame)
	if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		local humanoidRootPart = player.Character.HumanoidRootPart

		if (humanoidRootPart.Position - cFrame.Position).Magnitude > (player:GetAttribute("Stealing") and 4.5 or 7) then
			humanoidRootPart.CFrame = cFrame
		end
	end
end)