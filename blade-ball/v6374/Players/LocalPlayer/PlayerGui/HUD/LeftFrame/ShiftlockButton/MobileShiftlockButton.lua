local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage:WaitForChild("UserInputService"))
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")

while not workspace:GetAttribute("ClientModulesLoaded") do
	workspace:GetAttributeChangedSignal("ClientModulesLoaded"):Wait()
end

local Utils = require(ReplicatedStorage2.Common.Utils)
local localPlayer = Players.LocalPlayer
local bottom = script.Parent.Parent.Bottom
local isShiftlock = localPlayer:WaitForChild("isShiftlock")

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

if UserInputService.TouchEnabled and not (UserInputService.KeyboardEnabled and UserInputService.GamepadEnabled and GuiService:IsTenFootInterface()) then
	local function update()
		script.Parent.Visible = not (bottom.BottomOptions.ShiftlockButton.Visible and bottom.BottomOptions.Visible)
	end

	bottom.BottomOptions.ShiftlockButton:GetAttributeChangedSignal("Visible"):Connect(update)
	bottom.BottomOptions:GetPropertyChangedSignal("Visible"):Connect(update)
	task.spawn(update)
end

Utils.GuiUtils.mirrorActivated(script.Parent, bottom.BottomOptions.ShiftlockButton)