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

	if not (humanoidRootPart and humanoidRootPart2 and humanoid) then
		return
	end

	if humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	local lowerTorso = localPlayer.Character and localPlayer.Character == victim and victim:FindFirstChild("LowerTorso")

	if lowerTorso then
		workspace.CurrentCamera.CameraSubject = lowerTorso
	end

	local cframe = CFrame.Angles(0, 6.283185307179586 * math.random(), 0)
	FastRenderer.new({
		Time = 15
	}, function(_)
		if not (grabFolder.Parent and humanoidRootPart2.Anchored) or (humanoid.Health <= 0 or humanoid.Sit) then
			return true
		end

		local bone011 = followPart:FindFirstChild("Bone.011", true)

		if bone011 then
			humanoidRootPart2.CFrame = bone011.WorldCFrame * cframe * CFrame.new(0, 0, -8.7)
			HighlightModule:Update()
		end
	end)

	if localPlayer.Character and localPlayer.Character == victim then
		workspace.CurrentCamera.CameraSubject = humanoid
	end
end