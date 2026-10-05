local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local FireworkConstants = require(ReplicatedStorage.Modules.Shared.Fireworks.FireworkConstants)
local FireworkController = require(ReplicatedStorage.Modules.Client.Fireworks.FireworkController)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local localPlayer = Players.LocalPlayer
local v = Component.new({
	Tag = "FireworkPurchasePrompt"
})

function v:Construct()
	self._Janitor = Janitor.new()
	local fireworkType = self.Instance:GetAttribute("FireworkType")

	if typeof(fireworkType) == "string" and FireworkConstants.IsFireworkTypeName(fireworkType) then
		if FireworkConstants.RequiresInventory(fireworkType) then
			self.fireworkType = fireworkType
			return
		end

		warn("FireworkPurchasePrompt FireworkType is not a paid inventory type on", self.Instance:GetFullName())
	else
		warn("FireworkPurchasePrompt missing valid FireworkType attribute on", self.Instance:GetFullName())
	end

	self.fireworkType = nil
end

function v:Start()
	if self.fireworkType == nil then
		return
	end

	if self.Instance:IsA("ProximityPrompt") then
		self._Janitor:Add(self.Instance.Triggered:Connect(function(player)
			if player ~= localPlayer then
				return
			end

			local promptPurchase = FireworkController.PromptPurchase(self.fireworkType, "MallFireworkStand")

			if promptPurchase == "AT_CAP" then
				NotificationController.NotifyCenter("Purchase limit reached.")
			elseif promptPurchase == "BACKEND_ERROR" then
				NotificationController.NotifyCenter("Could not start purchase. Try again.")
			end
		end))
	else
		warn("FireworkPurchasePrompt must be placed on a ProximityPrompt", self.Instance:GetFullName())
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v