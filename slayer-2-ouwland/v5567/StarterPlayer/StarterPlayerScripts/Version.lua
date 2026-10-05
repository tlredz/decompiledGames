local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local value = script:FindFirstChild("Value")
local text = value == nil and "" or tostring(value.Value)
warn((`version - {text}`))
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Version"
screenGui.ResetOnSpawn = false
screenGui.ScreenInsets = Enum.ScreenInsets.None
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 1000
screenGui.Enabled = text ~= ""
local textLabel = Instance.new("TextLabel")
textLabel.Name = "Label"
textLabel.AnchorPoint = Vector2.new(1, 1)
textLabel.Position = UDim2.new(1, -4, 1, -4)
textLabel.Size = UDim2.fromOffset(0, 11)
textLabel.AutomaticSize = Enum.AutomaticSize.X
textLabel.BackgroundTransparency = 1
textLabel.Text = text
textLabel.FontFace = Font.new(gameSettings.preferedFont.Family, Enum.FontWeight.Bold, Enum.FontStyle.Normal)
textLabel.TextSize = 11
textLabel.TextColor3 = Color3.new(1, 1, 1)
textLabel.TextTransparency = 0.45
textLabel.TextXAlignment = Enum.TextXAlignment.Right
textLabel.TextYAlignment = Enum.TextYAlignment.Bottom
textLabel.Parent = screenGui
screenGui.Parent = playerGui