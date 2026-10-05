local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage:WaitForChild("UserInputService"))
local GuiService = game:GetService("GuiService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

while not workspace:GetAttribute("ClientStarted") do
	workspace:GetAttributeChangedSignal("ClientStarted"):Wait()
end

require(ReplicatedStorage2.Packages.Promise)
local Replion = require(ReplicatedStorage2.Packages.Replion)
local Utils = require(ReplicatedStorage2.Common.Utils)
local localPlayer = Players.LocalPlayer
local v = false
local v2 = true
Replion.Client:AwaitReplion("Data", function(object)
	v2 = object:Get({
		"Settings",
		"Misc",
		"Shift Lock on Match",
		"Enabled"
	})
	object:OnChange({
		"Settings",
		"Misc",
		"Shift Lock on Match",
		"Enabled"
	}, function(p)
		v2 = p
	end)
end)
local isShiftlock = localPlayer:WaitForChild("isShiftlock")

if UserInputService.TouchEnabled and not (UserInputService.KeyboardEnabled and UserInputService.GamepadEnabled and GuiService:IsTenFootInterface()) then
	script.Parent.Visible = true
else
	script.Parent.Visible = false
end

Utils.GuiUtils.getActivatedSignal(script.Parent):Connect(function()
	v = true
	isShiftlock.Value = not isShiftlock.Value
end)

local function updateColors()
	local uIGradient = script.Parent.IMG.UIGradient
	local color

	if isShiftlock.Value then
		color = ColorSequence.new(Color3.fromHex("#55ff00"), Color3.fromHex("#aaff00"))
	else
		color = ColorSequence.new(Color3.fromHex("#ff6363"), Color3.fromHex("#ff5a5a"))
	end

	uIGradient.Color = color
end

isShiftlock.Changed:Connect(updateColors)
updateColors()

local function newCharacter(instance)
	instance.AncestryChanged:Connect(function(_, parent)
		if parent == workspace.Alive then
			if not v and v2 then
				isShiftlock.Value = true
			end
		elseif parent == workspace.Dead and not v then
			isShiftlock.Value = false
		end
	end)
end

;(localPlayer.Character or localPlayer.CharacterAdded:Wait()).AncestryChanged:Connect(function(_, parent)
	if parent == workspace.Alive then
		if not v and v2 then
			isShiftlock.Value = true
		end
	elseif parent == workspace.Dead and not v then
		isShiftlock.Value = false
	end
end)
localPlayer.CharacterAdded:Connect(newCharacter)