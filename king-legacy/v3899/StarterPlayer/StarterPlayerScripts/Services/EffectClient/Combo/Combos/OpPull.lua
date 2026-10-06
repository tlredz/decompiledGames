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

	if not (victim and character and following) then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	if typeof(victim) == "table" then
		FastRenderer.new({
			Time = 15
		}, function(_, p)
			if not following.Parent then
				return true
			end

			local v = nil

			for _, v2 in pairs(victim) do
				local humanoidRootPart2 = v2:FindFirstChild("HumanoidRootPart")
				local humanoid = v2:FindFirstChild("Humanoid")

				if not (humanoidRootPart2 and humanoid and humanoidRootPart2.Anchored) then
					continue
				end

				if humanoid.Health <= 0 or humanoid.Sit then
					continue
				end

				CFrame.new(humanoidRootPart2.Position, humanoidRootPart.Position)
				humanoidRootPart2.CFrame = humanoidRootPart2.CFrame:Lerp(
					humanoidRootPart.CFrame * CFrame.new(0, 0, -5) * CFrame.Angles(0, 3.141592653589793, 0),
					p * 8.5
				)
				v = true
			end

			if not v then
				return true
			end

			HighlightModule:Update()
		end)
		return
	end

	local humanoidRootPart2 = victim:FindFirstChild("HumanoidRootPart")
	local humanoid = victim:FindFirstChild("Humanoid")

	if not (humanoidRootPart2 and humanoid) or humanoid.Health <= 0 then
		return
	end

	local lowerTorso = localPlayer.Character and localPlayer.Character == victim and victim:FindFirstChild("LowerTorso")

	if lowerTorso then
		workspace.CurrentCamera.CameraSubject = lowerTorso
	end

	FastRenderer.new({
		Time = 15
	}, function(_, p)
		if not (humanoidRootPart2.Anchored and following.Parent) or (humanoid.Health <= 0 or humanoid.Sit) then
			return true
		end

		CFrame.new(humanoidRootPart2.Position, humanoidRootPart.Position)
		humanoidRootPart2.CFrame = humanoidRootPart2.CFrame:Lerp(
			humanoidRootPart.CFrame * CFrame.new(0, 0, -5) * CFrame.Angles(0, 3.141592653589793, 0),
			p * 8.5
		)
		HighlightModule:Update()
	end)

	if localPlayer.Character and localPlayer.Character == victim then
		workspace.CurrentCamera.CameraSubject = humanoid
	end
end