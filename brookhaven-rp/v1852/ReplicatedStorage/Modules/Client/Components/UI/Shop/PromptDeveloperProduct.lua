local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local DevProductController = require(ReplicatedStorage.Modules.Client.Monetization.DevProductController)
local DevProducts = require(ReplicatedStorage.Modules.Shared.PlayerData.DevProducts)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "PromptDeveloperProduct"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local developerProduct = self.Instance:GetAttribute("DeveloperProduct")
	local telemetrySource = self.Instance:GetAttribute("TelemetrySource")
	local instance = self.Instance
	local v2 = DevProducts.All[developerProduct]
	assert(v2, "unknown product " .. developerProduct)
	self._Janitor:Add(instance.Activated:Connect(function()
		if DevProductController.IsOwned(v2) then
			NotificationController.NotifyCenter("You already own this product!")
		else
			DevProductController.PromptPurchaseWithId(DevProducts.GetId(v2), telemetrySource)
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v