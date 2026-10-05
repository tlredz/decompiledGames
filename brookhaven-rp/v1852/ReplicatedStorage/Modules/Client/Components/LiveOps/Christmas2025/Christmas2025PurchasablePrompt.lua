local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Modules.Client.Components.LiveOps.Christmas2025.ChristmasUnlocked)
local ReplicatedDataController = require(ReplicatedStorage.Modules.Client.Data.ReplicatedDataController)
local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
require(ReplicatedStorage.Modules.Client.UI.PanelController)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
require(ReplicatedStorage.Modules.Client.Components.UI.ItemUnlockedPrompt)
local v = Component.new({
	Tag = "Christmas2025PurchasablePrompt"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self.Name = self.Instance:GetAttribute("Christmas2025PurchasablePrompt_Name")
	self.Price = self.Instance:GetAttribute("Christmas2025PurchasablePrompt_Price")
	self.Icon = self.Instance:GetAttribute("Christmas2025PurchasablePrompt_Icon")
	self.DisplayName = self.Instance:GetAttribute("Christmas2025PurchasablePrompt_DisplayName")
end

function v:Start()
	if not self.Instance:IsA("ProximityPrompt") then
		return
	end

	if UnlockableController.IsFeatureUnlocked(self.Name) then
		self.Instance:Destroy()
	else
		self._Janitor:Add(self.Instance.Triggered:Connect(function(_)
			if UnlockableController.IsFeatureUnlocked(self.Name) then
				self.Instance:Destroy()
				return
			end

			local snowflakes = ReplicatedDataController.GetClientReplicaPromise():expect().Data.LiveOpsEventData.Christmas2025.Snowflakes

			if snowflakes == nil then
				return
			end

			if snowflakes < self.Price then
				NotificationController.NotifyCenter("You do not have enough snowflakes to buy this!", 3)
			elseif Remotes.invokeServer("Christmas2025_ExchangeItem", self.Name) then
				self.Instance:Destroy()
			else
				NotificationController.NotifyCenter("An error occurred buying this item, please try again", 3)
			end
		end))
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v