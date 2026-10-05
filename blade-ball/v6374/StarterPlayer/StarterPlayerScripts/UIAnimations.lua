local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require(ReplicatedStorage2:WaitForChild("UserInputService"))

while not workspace:GetAttribute("ClientModulesLoaded") do
	workspace:GetAttributeChangedSignal("ClientModulesLoaded"):Wait()
end

local UIHover = require(ReplicatedStorage.ClientGameModules.UIHover)
local GuiHandler = require(ReplicatedStorage.ClientGameModules.GuiHandler)

local function createScaleButton(button)
	assert(button:IsA("GuiButton"), (`Expect a GuiButton got a {button.ClassName} at {button:GetFullName()}`))
	button.MouseEnter:Connect(function()
		UIHover.Enter(button)
	end)
	button.MouseLeave:Connect(function()
		UIHover.Exit(button)
	end)

	if button.Name == "X" then
		local screenGui = button:FindFirstAncestorWhichIsA("ScreenGui")
		button.Activated:Connect(function()
			UIHover.Exit(button)

			if screenGui then
				GuiHandler:Close(screenGui.Name, true)
			end
		end)
	end

	button.SelectionGained:Connect(function()
		UIHover.Enter(button)
	end)
	button.SelectionLost:Connect(function()
		UIHover.Exit(button)
	end)
end

for _, v in CollectionService:GetTagged("ScaleButton") do
	task.spawn(createScaleButton, v)
end

CollectionService:GetInstanceAddedSignal("ScaleButton"):Connect(createScaleButton)