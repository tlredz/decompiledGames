local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = game.Players.LocalPlayer
require(ReplicatedStorage.client.legacyControllers.SettingsController)
script.Parent.Equipped:Connect(function()
	local UserInputService = game:GetService("UserInputService")

	if UserInputService.PreferredInput == Enum.PreferredInput.Gamepad then
		local GamepadService = game:GetService("GamepadService")
		GamepadService:EnableGamepadCursor(localPlayer.PlayerGui:WaitForChild("hud"):WaitForChild("safezone"):WaitForChild("bestiary"))
	end

	localPlayer.PlayerGui.backpack.inventory.Visible = false

	if localPlayer then
		local equipment = localPlayer.PlayerGui:WaitForChild("hud"):WaitForChild("safezone"):WaitForChild("equipment")
		equipment.Visible = true
		local deviceinset = localPlayer.PlayerGui:WaitForChild("hud"):WaitForChild("deviceinset")
		deviceinset.Enabled = false
	end
end)
script.Parent.Unequipped:Connect(function()
	local GamepadService = game:GetService("GamepadService")
	GamepadService:DisableGamepadCursor()

	if localPlayer then
		local equipment = localPlayer.PlayerGui:WaitForChild("hud"):WaitForChild("safezone"):WaitForChild("equipment")
		equipment.Visible = false
		local equipment_2 = localPlayer.PlayerGui:WaitForChild("hud"):WaitForChild("safezone"):WaitForChild("equipment")
		equipment_2.Visible = false
		local deviceinset = localPlayer.PlayerGui:WaitForChild("hud"):WaitForChild("deviceinset")
		deviceinset.Enabled = true
	end
end)