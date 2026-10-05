local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local v = Component.new({
	Tag = "CloseStarterInstructions"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local instance = self.Instance

	if instance:IsA("GuiButton") then
		self._Janitor:Add(instance.Activated:Connect(function()
			PanelController.Close("MainGUIHandler", "StarterInstructions")
		end))
	end

	local targetPanel = instance:GetAttribute("TargetPanel")

	if typeof(targetPanel) == "string" then
		local targetContext = instance:GetAttribute("TargetContext")
		local v2 = typeof(targetContext) ~= "string" and "MainGUIHandler" or targetContext
		self._Janitor:Add(PanelController.OnPanelOpened:Connect(function(p2: string, p3: string)
			if p2 == v2 and p3 == targetPanel then
				PanelController.Close("MainGUIHandler", "StarterInstructions")
			end
		end))
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v