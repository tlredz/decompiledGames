local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("UserInputService")
local _ = workspace.CurrentCamera
local Players = game:GetService("Players")
Players = Players.LocalPlayer
local FastRenderer = require(ReplicatedStorage.Chest.Modules.FastRenderer)
local HighlightModule = require(ReplicatedStorage.Chest.Modules.HighlightModule)
return function(player)
	local enemies = player.Enemies
	local character = player.Character
	local comboingChecker = player.ComboingChecker

	if not (enemies and character and comboingChecker) then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and typeof(enemies) == "table") then
		return
	end

	FastRenderer.new({
		Time = 15
	}, function(_, _)
		if not comboingChecker.Parent then
			return true
		end

		local cFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -5)
		local phoenix_Model = character:FindFirstChild("Phoenix_Model")

		if phoenix_Model then
			local dEFspine005 = phoenix_Model:FindFirstChild("DEF-spine.005", true)

			if dEFspine005 then
				cFrame = dEFspine005.WorldCFrame * CFrame.new(0, 0, -6)
			end
		end

		local v2 = nil

		for _, enemy in pairs(enemies) do
			local humanoidRootPart2 = enemy:FindFirstChild("HumanoidRootPart")
			local humanoid = enemy:FindFirstChild("Humanoid")

			if not (humanoidRootPart2 and humanoid and humanoidRootPart2.Anchored) then
				continue
			end

			if humanoid.Health <= 0 or humanoid.Sit then
				continue
			end

			CFrame.new(humanoidRootPart2.Position, humanoidRootPart.Position)
			humanoidRootPart2.CFrame = cFrame
			v2 = true
		end

		if not v2 then
			return true
		end

		HighlightModule:Update()
	end)
end