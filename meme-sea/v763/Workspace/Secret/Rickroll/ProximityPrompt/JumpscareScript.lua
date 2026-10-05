local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = game.Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui", 60)
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
local sound_Effect = ReplicatedStorage:WaitForChild("Sound_Effect")
local Jumpscare = require(moduleScript:WaitForChild("Jumpscare"))
local PlaySound = require(moduleScript:WaitForChild("PlaySound"))
local parent = script.Parent
local name = parent.Parent.Name
parent.Triggered:Connect(function(player)
	local child = playerGui.Jumpscare:FindFirstChild(name)

	if child and localPlayer:GetAttribute("Jumpscaring") == nil then
		PlaySound.PlaySound(player, sound_Effect.RickRoll)
		Jumpscare.SetJumpscare(player, child)
	end
end)