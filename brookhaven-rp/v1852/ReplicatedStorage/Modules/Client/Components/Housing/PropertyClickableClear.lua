local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local PropertyPermissions = require(ReplicatedStorage.Modules.Client.Components.Housing.PropertyPermissions)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local ConfirmationPanel = require(ReplicatedStorage.Modules.Client.UI.ConfirmationPanel)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local v = Component.new({
	Tag = "PropertyClickableClear"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	self.propertyPermissions = ComponentUtil.FindAndWaitForAncestorComponent(
		self.Instance,
		"PropertyPermissions",
		PropertyPermissions
	)
	local clickDetector = self.Instance:WaitForChild("ClickDetector")
	self.debounce = false
	self._Janitor:Add(clickDetector.MouseClick:Connect(function(p)
		if self.debounce or not self.propertyPermissions:HasAnyRole(p, "Owner") then
			NotificationController.NotifyCenter("You do not have permission to do this.")
			return
		end

		self.debounce = true
		task.delay(0.4, function()
			self.debounce = false
		end)
		local panel = PanelController.GetPanel("NoResetGUIHandler", "ConfirmationPanel")

		if not panel then
			return
		end

		ComponentUtil.FindAndWaitForAncestorComponent(panel.Instance, "ConfirmationPanel", ConfirmationPanel):Init(
			"Are you sure you want to clear all props in this house?",
			function(flag: boolean)
				if flag then
					Remotes.fireServerComponent(self.Instance, "ClearProps", p)
				end
			end
		)
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v