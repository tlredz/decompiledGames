local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "HouseMailBoxDeleteMail"
})
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local HouseMailBox = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.House.HouseMailBox)
require(ReplicatedStorage.Modules.Client.Components.UI.Panels.Panel)

function v:Construct()
	self._Janitor = Janitor.new()
	local panel = PanelController.GetPanel("NoResetGUIHandler", "MailboxUI")

	if panel then
		self.mailboxUIPanel = panel
	else
		warn("HouseMailBoxDeleteMail: panel not found, why?")
	end
end

function v:Start()
	local instance = self.Instance
	self._Janitor:Add(instance.MouseButton1Click:Connect(function()
		HouseMailBox:GetAll()[1]:ClearMail()
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v