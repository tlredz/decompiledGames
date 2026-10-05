local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedDataController = require(ReplicatedStorage.Modules.Client.Data.ReplicatedDataController)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "PrivateServerMusicComponent"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	if self.Instance.Parent == nil then
		return
	end

	local v2, v3 = ReplicatedDataController.GetClientReplicaPromise():await()

	if not v2 then
		warn("PrivateServerMusicComponent: Failed to get client replica")
		return
	end

	local v4 = nil

	local function updateMuted(p2)
		if p2 then
			self.Instance:SetAttribute("StoredVolume", self.Instance.Volume)
			self.Instance.Volume = 0
			v4 = true
		elseif self.Instance:GetAttribute("StoredVolume") ~= nil then
			v4 = false
			self.Instance.Volume = self.Instance:GetAttribute("StoredVolume")
			self.Instance:SetAttribute("StoredVolume", nil)
		end
	end

	updateMuted(v3.Data.Settings.MusicMute)
	self._Janitor:Add(v3:OnSet({ "Settings", "MusicMute" }, function(p2)
		if v4 == p2 then
			return
		end

		updateMuted(p2)
	end), "Disconnect")
	local v5 = false
	self._Janitor:Add(self.Instance:GetPropertyChangedSignal("Volume"):Connect(function()
		if v4 and not v5 then
			self.Instance:SetAttribute("StoredVolume", self.Instance.Volume)
			v5 = true
			self.Instance.Volume = 0
			v5 = false
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v