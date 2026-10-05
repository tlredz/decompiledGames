local v = false
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local fx = require(ReplicatedStorage.shared.modules:WaitForChild("fx"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local legacyControllers = ReplicatedStorage2.client.legacyControllers
require(legacyControllers.InputController)
local localPlayer = Players.LocalPlayer
local v2 = {
	"DPadUp",
	"DPadDown",
	"DPadLeft",
	"ButtonX",
	"ButtonY"
}
local v3 = v2[math.random(1, #v2)]
local backslashToggled = localPlayer:GetAttribute("BackslashToggled") or UserInputService.GamepadEnabled

if script.Parent.Parent.Name == "safezone" and backslashToggled then
	GuiService.SelectedObject = script.Parent
end

local UserInputService2 = game:GetService("UserInputService")
UserInputService2.InputBegan:Connect(function(input)
	local _ = input.KeyCode == Enum.KeyCode[v3]

	if not (input.KeyCode == Enum.KeyCode.ButtonA and script.Parent.Parent.Name == "safezone") then
		return
	end

	if not v and GuiService.SelectedObject ~= script.Parent then
		script.Parent:FindFirstAncestorWhichIsA("ScreenGui"):WaitForChild("cancel"):FireServer()
		return
	end

	local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
	fx:PlaySound(
		ReplicatedStorage3:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("ui"):WaitForChild("popclick"),
		script.Parent.Parent,
		true
	)
end)
script.Parent.MouseButton1Click:Connect(function()
	local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
	fx:PlaySound(
		ReplicatedStorage3:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("ui"):WaitForChild("popclick"),
		script.Parent.Parent,
		true
	)
end)
script.Parent.MouseEnter:Connect(function()
	v = true
end)
script.Parent.MouseLeave:Connect(function()
	v = false
end)