local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local v = Component.new({
	Tag = "Summer2026PlusButton"
})

function v:Construct()
	self._Janitor = Janitor.new()
	local PanelController2 = require(ReplicatedStorage.Modules.Client.UI.PanelController)
	PanelController = PanelController2
end

function v:Start()
	self._Janitor:Add(self.Instance.Activated:Connect(function()
		if PanelController.IsOpen("MainGUIHandler", "Summer2026Menu") then
			PanelController.Close("MainGUIHandler", "Summer2026Menu")
			return
		end

		assert(PanelController.WaitForPanel("MainGUIHandler", "Summer2026Menu")).Instance:SetAttribute(
			"SummerSource",
			"Summer2026PlusButton"
		)
		PanelController.OpenPanelByContext("MainGUIHandler", "Summer2026Menu")
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v