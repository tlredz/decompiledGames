local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "HouseSignButton"
})
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local HousePanel = require(ReplicatedStorage.Modules.Client.Components.UI.Houses.HousePanel)
local HouseTelemetry = require(ReplicatedStorage.Modules.Client.Components.UI.Houses.HouseTelemetry)

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)

	if not ComponentUtil.FindAndWaitForAncestorComponent(self.Instance, "HousePanel", HousePanel) then
		return
	end

	local instance = self.Instance
	self._Janitor:Add(instance.MouseButton1Click:Connect(function()
		HouseTelemetry.Click(self.Tag)

		if not self.panel then
			return
		end

		if PanelController.IsOpen("MainGUIHandler", "HouseSign") then
			PanelController.Close("MainGUIHandler", "HouseSign")
			return
		end

		PanelController.ToggleGroup("HousePanels", false)
		PanelController.Open("MainGUIHandler", "HouseSign")
	end))
	self.panel = self.Instance.Panel.Value

	if not self.panel then
		return
	end

	self.panel:AddTag("Panel")
end

function v:Stop()
	self._Janitor:Destroy()
end

return v