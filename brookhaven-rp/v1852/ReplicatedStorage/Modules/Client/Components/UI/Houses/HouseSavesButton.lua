local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HouseTelemetry = require(ReplicatedStorage.Modules.Client.Components.UI.Houses.HouseTelemetry)
local MainButtonPopout = require(ReplicatedStorage.Modules.Client.Components.UI.MainButtonPopout)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "HouseSavesButton"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	self._Janitor:Add(self.Instance.Activated:Connect(function()
		HouseTelemetry.Click(self.Tag)

		if PanelController.IsOpen("MainGUIHandler", "MainHouseMenu") then
			PanelController.Close("MainGUIHandler", "MainHouseMenu")
			return
		end

		local HouseMenu = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.House.HouseMenu)
		local v2 = PanelController.WaitForPanel("MainGUIHandler", "MainHouseMenu")
		PanelController.OpenPanelByContext("MainGUIHandler", "MainHouseMenu")
		HouseMenu:WaitForInstance(v2:GetInstance()):expect():ShowSaves("HouseHUD")
		MainButtonPopout.Close()
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v