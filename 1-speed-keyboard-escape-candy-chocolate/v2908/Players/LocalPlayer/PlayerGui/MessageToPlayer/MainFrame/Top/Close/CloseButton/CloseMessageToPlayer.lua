local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local _ = Players.LocalPlayer
local parent = script.Parent
local screenGui = parent:FindFirstAncestorOfClass("ScreenGui")
local clearMessageToPlayer = ReplicatedStorage:WaitForChild("ClearMessageToPlayer")
parent.MouseButton1Click:Connect(function()
	clearMessageToPlayer:FireServer()

	if screenGui then
		screenGui.Enabled = false
	end
end)