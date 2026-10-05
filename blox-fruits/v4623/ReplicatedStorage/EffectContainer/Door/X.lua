local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local _ = workspace._WorldOrigin
game:GetService("TweenService")
local RunService = game:GetService("RunService")
return function(player)
	if player.Wake then
		if player.Player == game.Players.LocalPlayer then
			return
		end

		local character = player.Player.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		humanoidRootPart.CFrame = player.Wake
		task.wait()
		humanoidRootPart.CFrame = player.Wake + createVector(0, 0.011, 0)
		task.wait()
		humanoidRootPart.Velocity += createVector(0, 0.22, 0)
		humanoidRootPart.CFrame = player.Wake + createVector(0, 0.022, 0)
	else
		local character = player.Character
		local reference = player.Reference

		if character and character:IsDescendantOf(workspace) then
			if character == game.Players.LocalPlayer.Character then
				local clone = script.DoorCC:Clone()
				clone.Parent = game.Lighting

				while wait() and reference:IsDescendantOf(workspace) do

				end

				clone:Destroy()
			else
				character.HumanoidRootPart.Anchored = true

				while RunService.Stepped:Wait() and reference:IsDescendantOf(workspace) do
					character.HumanoidRootPart.CFrame = CFrame.new(999999, 999999, 999999)
				end

				character.HumanoidRootPart.Anchored = false
				character.HumanoidRootPart.CFrame += createVector(0, 0.011, 0)
				task.wait()
				character.HumanoidRootPart.Velocity += createVector(0, 0.22, 0)
				character.HumanoidRootPart.CFrame += createVector(0, 0.022, 0)
			end
		end
	end
end