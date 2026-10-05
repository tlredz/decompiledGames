local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.TelemetryController)
local LotUtil = require(ReplicatedStorage.Modules.Shared.Housing.LotUtil)
local PlayerBagUtil = require(ReplicatedStorage.Modules.Shared.PlayerData.PlayerBagUtil)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local t = require(ReplicatedStorage.Packages.t)
local v = Component.new({
	Tag = "HouseInteractablePanel"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self.interaction = self.Instance:GetAttribute("HouseInteraction")
	assert(
		t.string(self.interaction) and string.len(self.interaction) > 0,
		"Invalid HouseInteraction attribute for " .. self.Instance:GetFullName()
	)
end

function v:Start()
	self._Janitor:Add(self.Instance:WaitForChild("ClickDetector").MouseClick:Connect(function()
		local value = PlayerBagUtil.GetPlayerBagInstance(Players.LocalPlayer, "HouseNumber").Value
		local propertyRoot = LotUtil.GetPropertyRoot(value)

		if not propertyRoot then
			return
		end

		TelemetryController.SendClientInteraction("houseInteractablePanel", {
			houseId = propertyRoot:GetDisplayName(),
			interaction = self.interaction
		})
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v