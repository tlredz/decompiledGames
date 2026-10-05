local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "HidePropMakerModelSettings"
})
local v2 = false
local RunService = game:GetService("RunService")
local isServer = RunService:IsServer()
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)

function v:Construct()
	self._Janitor = Janitor.new()
	local ReplicatedDataController = require(ReplicatedStorage.Modules.Client.Data.ReplicatedDataController)
	v2 = ReplicatedDataController
	self.checkMark = self.Instance:WaitForChild("GreenCheckMark")
end

function v:Start()
	if isServer then
		return
	end

	local v3, v4 = v2.GetClientReplicaPromise():await()

	if v3 == false then
		warn("HideHouseSignSettings: Failed to get client replica")
		return
	end

	self.checkMark.Visible = v4.Data.Settings.HidePropMakerModel
	v4:OnSet({ "Settings", "HidePropMakerModel" }, function(visible)
		self.checkMark.Visible = visible
	end)
	self._Janitor:Add(self.Instance.MouseButton1Click:Connect(function()
		self.checkMark.Visible = not self.checkMark.Visible
		Remotes.fireServerComponent(self.Instance, "HidePropMakerModelSettingsToggle")
		local v5 = self.checkMark.Visible and "Prop Maker Model is now hidden!" or "Prop Maker Model is now visible!"
		NotificationController.NotifyCenter(v5, nil, nil, "hidePropMakerModel")
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v