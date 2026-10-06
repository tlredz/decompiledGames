local createVector = vector.create
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
	local following = player.Following
	local centerCF = player.CenterCF
	local pos = player.Pos

	if not (victim and character and following and centerCF and pos) then
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

	local total = 0
	FastRenderer.new({
		Time = 15
	}, function(p, p2)
		if not (humanoidRootPart2.Anchored and following.Parent) or (humanoid.Health <= 0 or humanoid.Sit) then
			return true
		end

		humanoidRootPart2.CFrame = CFrame.new(centerCF.Position, centerCF.Position + pos.Unit * createVector(1, 0, 1)) * CFrame.Angles(
			0,
			math.rad(p * 1440) * total,
			0
		) * CFrame.new(0, 0, -(75 - p * 50)) + createVector(0, 5, 0)
		HighlightModule:Update()
		total += p2
	end)

	if localPlayer.Character and localPlayer.Character == victim then
		workspace.CurrentCamera.CameraSubject = humanoid
	end
end