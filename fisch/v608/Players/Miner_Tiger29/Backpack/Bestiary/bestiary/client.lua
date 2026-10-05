local GamepadService = game:GetService("GamepadService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("Lighting")
game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
local playerGui = Players.LocalPlayer.PlayerGui
local hud = playerGui:WaitForChild("hud")
local backpack = playerGui:WaitForChild("backpack")
local safezone = hud:WaitForChild("safezone")
local bestiary = safezone:WaitForChild("bestiary")
local bestiaryNEW = safezone:WaitForChild("bestiaryNEW")
script.Parent.Equipped:Connect(function()
	local v = SettingsController:GetSettingValue("newBestiary") and bestiaryNEW or bestiary

	if UserInputService.PreferredInput == Enum.PreferredInput.Gamepad then
		GamepadService:EnableGamepadCursor(v)
	end

	v.Visible = true
	local deviceinset = hud:WaitForChild("deviceinset")
	deviceinset.Enabled = false
	backpack.inventory.Visible = false
end)
script.Parent.Unequipped:Connect(function()
	GamepadService:DisableGamepadCursor()
	bestiary.Visible = false
	bestiaryNEW.Visible = false
	local deviceinset = hud:WaitForChild("deviceinset")
	deviceinset.Enabled = true
end)