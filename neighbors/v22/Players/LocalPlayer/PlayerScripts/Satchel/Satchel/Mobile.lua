local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UI = require(ReplicatedStorage.Modules.UI)
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local backpackGui = playerGui:WaitForChild("BackpackGui")
local BUTTONS = playerGui:WaitForChild("MainMenu"):WaitForChild("ConnectedFrame"):WaitForChild("BUTTONS")

if UI:GetDeviceType() == "Mobile" then
	local uIScale = Instance.new("UIScale", backpackGui)
	uIScale.Scale = 0.85
	BUTTONS.Position = UDim2.new(0.5, 0, 1, -(5 + 80 * uIScale.Scale))
end