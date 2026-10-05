local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
game:GetService("ContentProvider")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local Trove = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Trove"))
local Net = require(ReplicatedStorage.packages.Net)
local module = require("./PassiveHandler")
local NotificationController = require(ReplicatedStorage.client.legacyControllers.NotificationController)
local HudController = require(ReplicatedStorage.client.legacyControllers.HudController)
local InventoryController = require(ReplicatedStorage.client.legacyControllers.InventoryController)
require(ReplicatedStorage.shared.modules.fx)
local Backpack = require(ReplicatedStorage.client.modules.ui.Backpack)
local rods = require(ReplicatedStorage.shared.modules.library.rods)
local quickModeSwap = ReplicatedStorage.client.inputs.QuickModeSwap
local remoteFunction = Net:RemoteFunction("Rod/CycleMode", -1)
local QuickModeSwap = {
	NoMock = true,
	Switch = function(self)
		local character = localPlayer.Character

		if not character then
			return
		end

		local tool = character:FindFirstChildOfClass("Tool")

		if not (tool and (HudController:GetBackpackGui().Enabled and HudController:GetHud().Enabled)) then
			return
		end

		if tool.Name == self.config.LinkedRod then
			local linkedRod = self.config.LinkedRod
			local v, v2 = remoteFunction:InvokeServer(linkedRod)

			if v then
				local mode = rods[linkedRod].Modes[v2]
				NotificationController:FancyNotify({
					Components = {
						{
							Type = "Text",
							Text = "Mode:"
						},
						{
							Type = "Icon",
							AssetId = mode.Icon,
							Size = 1.5
						},
						{
							Type = "Text",
							Text = `<font color="#{mode.Color:ToHex()}"><b>{mode.DisplayName}</b></font>`
						}
					},
					Sound = "changeVariant",
					ShineFlash = mode.Color
				})
				local v3 = Backpack.equipRod()

				if tool == v3 or not v3 then
					localPlayer.Backpack:WaitForChild(linkedRod)
					Backpack.equipRod()
				end
			elseif v2 then
				ReplicatedStorage.events.anno_localthought:Fire(v2)
			end
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
		local backpackGui = HudController:GetBackpackGui()
		local linkedSpearMobile = HudController:GetPlayerGui():WaitForChild("LinkedSpearMobile")

		local function updateMobileVisibility()
			quickModeSwap.Enabled = backpackGui.Enabled and InventoryController.EquippedTool and InventoryController.EquippedTool.Name == object.config.LinkedRod
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
		quickModeSwap.Enabled = backpackGui.Enabled and InventoryController.EquippedTool and InventoryController.EquippedTool.Name == object.config.LinkedRod
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
setmetatable(QuickModeSwap, module)
return QuickModeSwap