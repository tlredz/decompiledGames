local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local RunService = game:GetService("RunService")
local isServer = RunService:IsServer()
local v = false
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local v2 = Component.new({
	Tag = "MusicMuteSettings"
})

function v2:Construct()
	self._Janitor = Janitor.new()
	local ReplicatedDataController = require(ReplicatedStorage.Modules.Client.Data.ReplicatedDataController)
	v = ReplicatedDataController
	self.checkMark = self.Instance:WaitForChild("GreenCheckMark")
end

function v2:Start()
	if isServer then
		return
	end

	local v3, v4 = v.GetClientReplicaPromise():await()

	if v3 == false then
		warn("MusicMuteSettings: Failed to get client replica")
		return
	end

	self.checkMark.Visible = v4.Data.Settings.MusicMute
	v4:OnSet({ "Settings", "MusicMute" }, function(visible)
		self.checkMark.Visible = visible
	end)
	self._Janitor:Add(self.Instance.MouseButton1Click:Connect(function()
		self.checkMark.Visible = not self.checkMark.Visible
		local v5 = self.checkMark.Visible and "Music from other players is OFF" or "Music from other players is ON"
		NotificationController.NotifyCenter(v5, nil, nil, "musicFromOtherPlayersMute")
		Remotes.fireServerComponent(self.Instance, "MusicMuteSettingsToggle")
	end))
end

function v2:Stop()
	self._Janitor:Destroy()
end

return v2