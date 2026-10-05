local FeasterClass = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
Client.Events.FeasterUpgradeParticles:Connect(function(player)
	local humanoidRootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local clone = game.ReplicatedStorage.Assets.Particles.Feaster_Upgrade.VfxAttachment:Clone()
	task.delay(10, function()
		clone:Destroy()
	end)
	clone.Parent = humanoidRootPart
	Client.Utility.RunParticles(clone)
end)
Client.Events.FeasterEatParticles:Connect(function(player)
	local humanoidRootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	Client.Utility.SpawnParticles(
		"Feaster_Crumbs",
		humanoidRootPart.CFrame * CFrame.Angles(0, 0, 0) * CFrame.new(0, 1.5, -1.5)
	)
end)

function FeasterClass.Init() end

return FeasterClass