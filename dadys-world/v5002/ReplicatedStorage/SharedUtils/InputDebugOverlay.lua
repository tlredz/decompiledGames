local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InputConfig = require(ReplicatedStorage.SharedData.InputConfig)
return {
	start = function(object)
		local screenGui = Instance.new("ScreenGui")
		screenGui.Name = "InputDebugOverlay"
		screenGui.ResetOnSpawn = false
		screenGui.IgnoreGuiInset = true
		screenGui.DisplayOrder = 5000
		local textLabel = Instance.new("TextLabel")
		textLabel.AnchorPoint = Vector2.new(1, 0)
		textLabel.Position = UDim2.new(1, -8, 0, 8)
		textLabel.Size = UDim2.new(0, 280, 0, 220)
		textLabel.BackgroundTransparency = 0.4
		textLabel.BackgroundColor3 = Color3.new(0, 0, 0)
		textLabel.TextColor3 = Color3.new(1, 1, 1)
		textLabel.TextXAlignment = Enum.TextXAlignment.Left
		textLabel.TextYAlignment = Enum.TextYAlignment.Top
		textLabel.Font = Enum.Font.Code
		textLabel.TextSize = 14
		textLabel.Text = ""
		textLabel.Parent = screenGui
		screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
		RunService.RenderStepped:Connect(function()
			local v = { "INPUT  [" .. object:GetPreferredInput() .. "]" }

			for k in pairs(InputConfig.Actions) do
				table.insert(v, string.format("%-14s %s", k, (tostring(object:GetActionState(k)))))
			end

			textLabel.Text = table.concat(v, "\n")
		end)
	end
}