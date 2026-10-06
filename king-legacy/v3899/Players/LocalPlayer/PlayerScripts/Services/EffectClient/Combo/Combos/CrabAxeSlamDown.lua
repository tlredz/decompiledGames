local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("UserInputService")
local _ = workspace.CurrentCamera
local Players = game:GetService("Players")
Players = Players.LocalPlayer
local FastRenderer = require(ReplicatedStorage.Chest.Modules.FastRenderer)
local HighlightModule = require(ReplicatedStorage.Chest.Modules.HighlightModule)
return function(player)
	local victims = player.Victims
	local character = player.Character
	local time = player.Time

	if not (victims and character) then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	FastRenderer.new({
		Time = time
	}, function(_)
		for _, victim in pairs(victims) do
			local humanoid = victim:FindFirstChild("Humanoid")
			local humanoidRootPart2 = victim:FindFirstChild("HumanoidRootPart")

			if not (humanoid and humanoidRootPart2 and humanoidRootPart2.Anchored) then
				continue
			end

			if humanoid.Health <= 0 or humanoid.Sit then
				continue
			end

			humanoidRootPart2.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -1, -1.5)
		end

		HighlightModule:Update()
	end)
end