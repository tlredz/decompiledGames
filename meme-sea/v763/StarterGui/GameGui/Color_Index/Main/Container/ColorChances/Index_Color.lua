local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local otherEvent = ReplicatedStorage:WaitForChild("OtherEvent")
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
local colorAssets = ReplicatedStorage:WaitForChild("GuiTemplate"):WaitForChild("ColorAssets")
local Aura_Color = require(moduleScript:WaitForChild("Aura_Color"))
local Translate = require(moduleScript:WaitForChild("Translate"))
local auraColor = localPlayer:WaitForChild("Items", 60):WaitForChild("AuraColor")
local guiEvent = otherEvent.GuiEvents:WaitForChild("GuiEvent")
local parent = script.Parent
local _ = parent.Parent.Parent.Parent
local container = parent.Container
local indexColor_Template = colorAssets:WaitForChild("IndexColor_Template")
local rainbow_UIGradient = colorAssets:WaitForChild("Rainbow_UIGradient")
local chance = Aura_Color.Chance

local function GenerateIndex()
	for _, frame in ipairs(container:GetChildren()) do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end

	for childName, v in pairs(chance) do
		local clone = indexColor_Template:Clone()
		clone.Name = childName
		clone.Example.ImageColor3 = Aura_Color.ConvertColor[childName] or Color3.fromRGB(255, 255, 255)

		if localPlayer:GetAttribute("TH") then
			clone.Title.Text = Translate[childName]
		else
			clone.Title.Text = childName
		end

		clone.Chances.Text = `{v}%`
		clone.LayoutOrder = (20 - v) * 10

		if clone.Name == "Spectrum" then
			local uIGradient = clone.Example:FindFirstChild("UIGradient")

			if uIGradient and clone.Name == "Spectrum" then
				uIGradient:Destroy()
			end

			local clone_2 = rainbow_UIGradient:Clone()
			clone_2.Parent = clone.Example
		end

		if auraColor:FindFirstChild(childName) and auraColor:FindFirstChild(childName).Value == true then
			clone.Locked.Visible = false
		end

		clone.Visible = true
		clone.Parent = container
	end
end

guiEvent.Event:Connect(function(p)
	local menuName = p.MenuName
	local action = p.Action

	if menuName == "ColorIndex" and action == "Refresh" then
		GenerateIndex()
	end
end)