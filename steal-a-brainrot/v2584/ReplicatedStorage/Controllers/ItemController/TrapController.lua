local Players = game:GetService("Players")
game:GetService("Lighting")
game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local _ = Players.LocalPlayer
local _ = workspace.CurrentCamera
local controllers = ReplicatedStorage:WaitForChild("Controllers")
require(controllers.CharacterController)
local packages = ReplicatedStorage:WaitForChild("Packages")
local Net = require(packages.Net)
Net:RemoteEvent("UseItem").OnClientEvent:Connect(function(p, p2: string, instance)
	if not (p == "Trapped" and p2 == "PlaySound") then
		return
	end

	local sound = instance:FindFirstChildWhichIsA("Sound", true)

	if sound then
		sound:Play()
	end
end)
return {}