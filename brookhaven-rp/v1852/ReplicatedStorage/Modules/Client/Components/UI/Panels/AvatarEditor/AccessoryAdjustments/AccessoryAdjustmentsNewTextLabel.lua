local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "AccessoryAdjustmentsNewTextLabel"
})
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local instance = self.Instance
	instance.Visible = false
	local parent = instance.Parent
	self._Janitor:Add(parent.MouseEnter:Connect(function()
		instance.Visible = false
	end))
	self._Janitor:Add(parent.Activated:Connect(function()
		instance.Visible = false
	end))

	if not NotificationController.IsWarningAcknowledged("accessoryAdjustmentsNew") then
		instance.Visible = true
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v