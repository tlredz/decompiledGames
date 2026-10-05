local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local SoundManager = require(ReplicatedStorage:WaitForChild("SoundManager"))
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

-- equivalent calls inferred from this helper; original call sites unknown
local function isInsideMainGui(button)
	local screenGui = button:FindFirstAncestorOfClass("ScreenGui")

	if screenGui and CollectionService:HasTag(screenGui, "MainGUI") then
		return true
	end

	return false
end

local function handleButton(button)
	if not button:IsA("GuiButton") then
		return
	end

	if isInsideMainGui(button) then
		button.MouseEnter:Connect(function()
			if button.Visible and button.Active and not CollectionService:HasTag(button, "SoundButton") then
				SoundManager:Play("HOVER")
			end
		end)
		button.MouseButton1Click:Connect(function()
			if button.Visible and button.Active then
				SoundManager:Play("CLICK")
			end
		end)
	end
end

for _, descendant in ipairs(playerGui:GetDescendants()) do
	handleButton(descendant)
end

playerGui.DescendantAdded:Connect(function(descendant)
	handleButton(descendant)
end)