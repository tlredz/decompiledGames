local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "HouseDisastersButton"
})
local HouseTelemetry = require(ReplicatedStorage.Modules.Client.Components.UI.Houses.HouseTelemetry)

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local Players = game:GetService("Players")
	local localPlayer = Players.LocalPlayer
	local PlayerBagUtil = require(ReplicatedStorage.Modules.Shared.PlayerData.PlayerBagUtil)
	local HouseUtil = require(ReplicatedStorage.Modules.Shared.Game.HouseUtil)
	local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
	local value = PlayerBagUtil.GetPlayerBagInstance(localPlayer, "HouseNumber").Value

	if HouseUtil.GetHouseType(value) == "Motel" then
		self.Instance.Visible = false
		return
	end

	local LotUtil = require(ReplicatedStorage.Modules.Shared.Housing.LotUtil)
	local property = LotUtil.GetProperty(value)

	if property == nil or not property:HasTag("PropertyDisasters") then
		self.Instance.Visible = false
		return
	end

	self._Janitor:Add(self.Instance.MouseButton1Click:Connect(function()
		HouseTelemetry.Click(self.Tag)

		if PanelController.IsOpen("MainGUIHandler", "ModalDisasterControls") then
			PanelController.Close("MainGUIHandler", "ModalDisasterControls")
			return
		end

		PanelController.ToggleGroup("HousePanels", false)
		PanelController.Open("MainGUIHandler", "ModalDisasterControls")
	end))
	self._Janitor:Add(PanelController.OnPanelOpened:Connect(function(p: string, p2: string)
		if p == "MainGUIHandler" and p2 == "ModalDisasterControls" then
			self.Instance.GreenCheckMark.Visible = true
		end
	end))
	self._Janitor:Add(PanelController.OnPanelClosed:Connect(function(p: string, p2: string)
		if p == "MainGUIHandler" and p2 == "ModalDisasterControls" then
			self.Instance.GreenCheckMark.Visible = false
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v