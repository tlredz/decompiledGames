game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CountableDevProductController = require(ReplicatedStorage.Modules.Client.Monetization.CountableDevProductController)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local CountableDevProducts = require(ReplicatedStorage.Modules.Shared.PlayerData.CountableDevProducts)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "PromptCountableDevProduct"
})

function v:Construct()
	self._Janitor = Janitor.new()
	local countableDevProduct = self.Instance:GetAttribute("CountableDevProduct")
	self.product = CountableDevProducts.All[countableDevProduct]
	assert(self.product, "unknown countable dev product " .. tostring(countableDevProduct))
	self.telemetrySource = self.Instance:GetAttribute("TelemetrySource")
end

function v:Start()
	local instance = self.Instance
	self._Janitor:Add(instance.Triggered:Connect(function()
		local promptPurchase = CountableDevProductController.PromptPurchase(self.product, self.telemetrySource)

		if promptPurchase == "AT_CAP" then
			NotificationController.NotifyCenter("Purchase limit reached.")
		elseif promptPurchase == "BACKEND_ERROR" then
			NotificationController.NotifyCenter("Could not start purchase. Try again.")
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v