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
	local grabFolder = player.GrabFolder

	if not (victim and character and grabFolder and character:FindFirstChild("HumanoidRootPart")) then
		return
	end

	local humanoidRootPart = victim:FindFirstChild("HumanoidRootPart")
	local humanoid = victim:FindFirstChild("Humanoid")

	if not (humanoidRootPart and humanoid) or humanoid.Health <= 0 then
		return
	end

	local lowerTorso = localPlayer.Character and localPlayer.Character == victim and victim:FindFirstChild("LowerTorso")

	if lowerTorso then
		workspace.CurrentCamera.CameraSubject = lowerTorso
	end

	local cframe = CFrame.Angles(
		6.283185307179586 * math.random(),
		6.283185307179586 * math.random(),
		6.283185307179586 * math.random()
	)
	FastRenderer.new({
		Time = 15
	}, function(_, _)
		if not humanoidRootPart.Anchored or (humanoid.Health <= 0 or humanoid.Sit) then
			return true
		end

		local metalBall = character:FindFirstChild("MetalBall")
		local ball = metalBall and metalBall.RootPart:FindFirstChild("Ball", true)

		if ball then
			local worldCFrame = ball.WorldCFrame
			humanoidRootPart.CFrame = CFrame.new((worldCFrame * CFrame.new(0, 5, 0)).Position) * cframe * CFrame.new(
				0,
				4,
				0
			) * CFrame.Angles(1.5707963267948966, 0, 0)
		end

		HighlightModule:Update()
	end)

	if localPlayer.Character and localPlayer.Character == victim then
		workspace.CurrentCamera.CameraSubject = humanoid
	end
end