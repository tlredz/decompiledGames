local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
game:GetService("ContentProvider")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local Trove = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Trove"))
local Net = require(ReplicatedStorage.packages.Net)
local module = require("./PassiveHandler")
local HudController = require(ReplicatedStorage.client.legacyControllers.HudController)
local InventoryController = require(ReplicatedStorage.client.legacyControllers.InventoryController)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local playerDataReplicator = DataController.PlayerDataReplicator
require(ReplicatedStorage.shared.modules.fx)
local Backpack = require(ReplicatedStorage.client.modules.ui.Backpack)
local quickModeSwap = ReplicatedStorage.client.inputs.QuickModeSwap
require(ReplicatedStorage.shared.modules.library.rods)
local remoteFunction = Net:RemoteFunction("HarpoonGun/SetEquipped")
local HarpoonGunConversion = {
	NoMock = true,
	Switch = function(self)
		local character = localPlayer.Character

		if not character then
			return
		end

		local tool = character:FindFirstChildOfClass("Tool")

		if not tool then
			return
		end

		if tool.Name == self.config.LinkedRod then
			remoteFunction:InvokeServer(self.config.LinkedHarpoon)
			Backpack.handleInput(self.config.LinkedHarpoon, "equip")
		elseif tool.Name == self.config.LinkedHarpoon then
			Backpack.handleInput(self.config.LinkedRod, "equip")
		end
	end,
	new = function(p, config, env)
		local object = setmetatable({}, {
			__index = p
		})
		object.config = config
		object.trove = Trove.new()
		object.reelTrove = object.trove:Extend()
		object.env = env
		object.uid = game.HttpService:GenerateGUID(false)
		playerDataReplicator:WaitForLoaded()

		if playerDataReplicator:TryIndex({ "Rods", object.config.LinkedRod, "enchant" }) == "Restricted" then
			return object
		end

		local backpackGui = HudController:GetBackpackGui()
		local linkedSpearMobile = HudController:GetPlayerGui():WaitForChild("LinkedSpearMobile")

		local function updateMobileVisibility()
			quickModeSwap.Enabled = backpackGui.Enabled and InventoryController.EquippedTool and (InventoryController.EquippedTool.Name == object.config.LinkedRod or InventoryController.EquippedTool.Name == object.config.LinkedHarpoon)
			linkedSpearMobile.Enabled = UserInputService.PreferredInput == Enum.PreferredInput.Touch and quickModeSwap.Enabled
		end

		object.trove:Add(quickModeSwap.QuickSwapMode.Pressed:Connect(function()
			object:Switch()
		end))
		object.trove:Add(UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(updateMobileVisibility))
		object.trove:Add(InventoryController.EquippedToolChanged:Connect(updateMobileVisibility))
		object.trove:Add(backpackGui:GetPropertyChangedSignal("Enabled"):Connect(updateMobileVisibility))
		object.trove:Add(function()
			linkedSpearMobile.Enabled = false
			quickModeSwap.Enabled = false
		end)
		quickModeSwap.Enabled = backpackGui.Enabled and InventoryController.EquippedTool and (InventoryController.EquippedTool.Name == object.config.LinkedRod or InventoryController.EquippedTool.Name == object.config.LinkedHarpoon)
		local enabled

		if UserInputService.PreferredInput == Enum.PreferredInput.Touch then
			enabled = quickModeSwap.Enabled
		else
			enabled = false
		end

		linkedSpearMobile.Enabled = enabled
		return object
	end
}
setmetatable(HarpoonGunConversion, module)
return HarpoonGunConversion