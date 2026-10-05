local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "VehicleClickDetectorOpenTextEdit"
})
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)

function v:Construct()
	self._Janitor = Janitor.new()
end

function v.Start(_)
	if PanelController.IsUnloadedLazyPanel("MainGUIHandler", "ModalVehicleTextEdit") then
		PanelController.LoadLazy("MainGUIHandler", "ModalVehicleTextEdit", false)
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v