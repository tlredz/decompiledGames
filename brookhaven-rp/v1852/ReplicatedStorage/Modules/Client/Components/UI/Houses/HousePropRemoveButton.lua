local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HouseTelemetry = require(ReplicatedStorage.Modules.Client.Components.UI.Houses.HouseTelemetry)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local ConfirmationPanel = require(ReplicatedStorage.Modules.Client.UI.ConfirmationPanel)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local v = Component.new({
	Tag = "HousePropRemoveButton"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local LotUtil = require(ReplicatedStorage.Modules.Shared.Housing.LotUtil)
	local houseNumber = game.Players.LocalPlayer.PlayersBag:FindFirstChild("HouseNumber")
	local propertyPermissions = LotUtil.GetPropertyPermissions(houseNumber.Value)
	local instance = self.Instance
	self._Janitor:Add(instance.MouseButton1Click:Connect(function()
		HouseTelemetry.Click(self.Tag)
		local panel = PanelController.GetPanel("NoResetGUIHandler", "ConfirmationPanel")

		if not panel then
			return
		end

		ComponentUtil.FindAndWaitForAncestorComponent(panel.Instance, "ConfirmationPanel", ConfirmationPanel):Init(
			"Are you sure you want to clear all props in this house?",
			function(flag: boolean)
				if flag then
					propertyPermissions:ClearProps()
				end
			end
		)
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v