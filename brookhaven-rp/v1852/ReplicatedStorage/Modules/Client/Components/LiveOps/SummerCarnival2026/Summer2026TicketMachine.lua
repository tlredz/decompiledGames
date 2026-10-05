local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "Summer2026TicketMachine"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local function open()
		assert(PanelController.WaitForPanel("MainGUIHandler", "Summer2026Menu")).Instance:SetAttribute(
			"SummerSource",
			"Summer2026TicketMachine"
		)
		PanelController.OpenPanelByContext("MainGUIHandler", "Summer2026Menu")
	end

	if self.Instance:IsA("ClickDetector") then
		local instance = self.Instance
		self._Janitor:Add(instance.MouseClick:Connect(open))
	elseif self.Instance:IsA("ProximityPrompt") then
		local instance = self.Instance
		self._Janitor:Add(instance.Triggered:Connect(open))
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v