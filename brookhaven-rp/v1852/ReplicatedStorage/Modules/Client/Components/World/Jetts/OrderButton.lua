local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local JettsOrderMenu = require(ReplicatedStorage.Modules.Client.Components.UI.World.Jetts.JettsOrderMenu)
require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local v = Component.new({
	Tag = "OrderButton"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self.debounce = false
end

function v:OpenOrderMenu()
	local v2 = PanelController.WaitForPanel("Jetts", "JettsOrderMenu")
	local source = self.Instance:GetAttribute("Source") or "Unknown"
	JettsOrderMenu:WaitForInstance(v2.Instance):expect():Reset(source)
	PanelController.OpenPanelByContext("Jetts", "JettsOrderMenu")
end

function v:Start()
	local clickDetector = self.Instance:WaitForChild("ClickDetector", 10)
	self._Janitor:Add(clickDetector.MouseClick:Connect(function()
		if self.debounce then
			return
		end

		self.debounce = true
		task.delay(0.5, function()
			self.debounce = false
		end)
		self:OpenOrderMenu()
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v