local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.TelemetryController)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = Component.new({
	Tag = "PurchaseRobloxPlus"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	self._Janitor:Add(self.Instance.Activated:Connect(function()
		if Players.LocalPlayer.HasRobloxSubscription then
			return
		end

		local plusPrompt = self.Instance:GetAttribute("PlusPrompt")
		local plusEvent = self.Instance:GetAttribute("PlusEvent")
		local plusItem = self.Instance:GetAttribute("PlusItem")
		TelemetryController.SendClientInteraction("robloxPlusPopup", {
			event = plusEvent,
			item = plusItem
		})

		if plusPrompt == true then
			Remotes.fireServer("PlusUpsell", plusEvent, plusItem)
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v