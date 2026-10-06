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
	local alpha = player.Alpha

	if not (victim and character and following and centerCF and pos and alpha) then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoidRootPart2 = victim:FindFirstChild("HumanoidRootPart")
	local humanoid = victim:FindFirstChild("Humanoid")

	if not (humanoidRootPart and humanoidRootPart2 and humanoid) then
		return
	end

	if humanoid.Health <= 0 or humanoid.Sit then
		return true
	end

	local lowerTorso = localPlayer.Character and localPlayer.Character == victim and victim:FindFirstChild("LowerTorso")

	if lowerTorso then
		workspace.CurrentCamera.CameraSubject = lowerTorso
	end

	FastRenderer.new({
		Time = 3
	}, function(p)
		local v = math.min(p + alpha, 1)

		if not (humanoidRootPart2.Anchored and following.Parent) or (humanoid.Health <= 0 or humanoid.Sit) then
			return true
		end

		humanoidRootPart2.CFrame = CFrame.new(centerCF.Position, centerCF.Position + pos.Unit * createVector(1, 0, 1)) * CFrame.Angles(
			0,
			-math.rad(p * 1440) * 1,
			0
		) * CFrame.new(0, 0, -math.cos(1.5707963267948966 * v) * 50) + createVector(0, 5, 0)
		HighlightModule:Update()
	end)

	if localPlayer.Character and localPlayer.Character == victim then
		workspace.CurrentCamera.CameraSubject = humanoid
	end
end