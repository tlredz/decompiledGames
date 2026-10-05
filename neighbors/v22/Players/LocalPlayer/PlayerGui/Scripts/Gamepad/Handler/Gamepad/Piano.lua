local Players = game:GetService("Players")
game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Gamepad = require(ReplicatedStorage.Modules.Gamepad)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

local function isPianoVisible()
	if playerGui:FindFirstChild("PianoGui") and playerGui.PianoGui:GetAttribute("Visible") or playerGui:FindFirstChild("PV2Piano") and playerGui.PV2Piano:GetAttribute("Visible") then
		return true
	end

	return false
end

while task.wait() do
	if not Gamepad.GamepadEnabled then
		continue
	end

	if not (playerGui:FindFirstChild("PianoGui") and playerGui.PianoGui:GetAttribute("Visible") or playerGui:FindFirstChild("PV2Piano") and playerGui.PV2Piano:GetAttribute("Visible")) then
		continue
	end

	local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid")

	if humanoid then
		humanoid.Jump = true
	end
end