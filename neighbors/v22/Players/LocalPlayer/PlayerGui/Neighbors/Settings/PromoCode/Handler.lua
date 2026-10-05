local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UI = require(ReplicatedStorage.Modules.UI)
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local codes = script.Parent.Header.Buttons.Codes
codes.Button.Activated:Connect(function()
	playerGui.Prompts.PromoCode.Visible = not playerGui.Prompts.PromoCode.Visible
end)
UI:AddShadowOnHover(codes)
UI:Bind(codes.Button)