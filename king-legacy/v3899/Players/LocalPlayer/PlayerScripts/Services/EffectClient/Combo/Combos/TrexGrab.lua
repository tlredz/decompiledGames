local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("UserInputService")
local _ = workspace.CurrentCamera
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local FastRenderer = require(ReplicatedStorage.Chest.Modules.FastRenderer)
local HighlightModule = require(ReplicatedStorage.Chest.Modules.HighlightModule)
return function(player)
	local victim = player.Victim
	local character = player.Character
	local followPart = player.FollowPart
	local grabFolder = player.GrabFolder

	if not (victim and character and followPart and grabFolder) then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoidRootPart2 = victim:FindFirstChild("HumanoidRootPart")
	local humanoid = victim:FindFirstChild("Humanoid")

	if not (humanoidRootPart and humanoidRootPart2 and humanoid) or humanoid.Health <= 0 then
		return
	end

	local lowerTorso = localPlayer.Character and localPlayer.Character == victim and victim:FindFirstChild("LowerTorso")

	if lowerTorso then
		workspace.CurrentCamera.CameraSubject = lowerTorso
	end

	FastRenderer.new({
		Time = 15
	}, function(_)
		if not (grabFolder.Parent and humanoidRootPart2.Anchored) or (humanoid.Health <= 0 or humanoid.Sit) then
			return true
		end

		local dEFjaw = followPart:FindFirstChild("DEF-jaw", true)

		if dEFjaw then
			humanoidRootPart2.CFrame = dEFjaw.WorldCFrame * CFrame.new(0, 15, -5.4)
			HighlightModule:Update()
		end
	end)

	if localPlayer.Character and localPlayer.Character == victim then
		workspace.CurrentCamera.CameraSubject = humanoid
	end
end