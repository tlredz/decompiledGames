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
	local vect3 = player.Vect3

	if not (victim and character and following and character:FindFirstChild("HumanoidRootPart")) then
		return
	end

	if typeof(victim) == "table" then
		FastRenderer.new({
			Time = 15
		}, function(_, _)
			if not following.Parent then
				return true
			end

			local v = nil

			for _, v2 in pairs(victim) do
				local humanoidRootPart = v2:FindFirstChild("HumanoidRootPart")
				local humanoid = v2:FindFirstChild("Humanoid")

				if not (humanoidRootPart and humanoid and humanoidRootPart.Anchored) then
					continue
				end

				if humanoid.Health <= 0 or humanoid.Sit then
					continue
				end

				humanoidRootPart.CFrame = vect3.Value
				v = true
			end

			if not v then
				return true
			end

			HighlightModule:Update()
		end)
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

	FastRenderer.new({
		Time = 15
	}, function(_, _)
		if not (humanoidRootPart.Anchored and following.Parent) or (humanoid.Health <= 0 or humanoid.Sit) then
			return true
		end

		humanoidRootPart.CFrame = vect3.Value
		HighlightModule:Update()
	end)

	if localPlayer.Character and localPlayer.Character == victim then
		workspace.CurrentCamera.CameraSubject = humanoid
	end
end