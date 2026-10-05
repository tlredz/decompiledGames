local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UI = require(ReplicatedStorage.Modules.UI)
local Version = require(ReplicatedStorage.Assets.Data.Version)
local updateLog = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Prompts"):WaitForChild("UpdateLog")
local version = script.Parent.Header.Buttons.Version
local Server = require(ReplicatedStorage.Modules.Server)
local v = string.format("%0.1f", Version[1].Version)

if RunService:IsStudio() then
	v = `Studio {v}`
elseif Server:IsTestServer() then
	v = `Test {v}`
elseif Server:IsAdultServer() then
	v = `18+ {v}`
end

version.Button.Text = `Version {v}`
version.Button.Activated:Connect(function()
	updateLog.Visible = not updateLog.Visible
end)
UI:Bind(version.Button)
UI:AddShadowOnHover(version)