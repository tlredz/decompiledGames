local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "HouseHideHouseSign"
})
local ReplicatedDataController = require(ReplicatedStorage.Modules.Client.Data.ReplicatedDataController)

function v:ToggleVisible(enabled: boolean)
	local surfaceGui = self.Instance:FindFirstChildWhichIsA("SurfaceGui")

	if surfaceGui then
		surfaceGui.Enabled = enabled
	else
		warn("HouseHideHouseSign: No surface gui found")
	end
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local v2, v3 = ReplicatedDataController.GetClientReplicaPromise():await()

	if v2 == false then
		warn("HouseHideHouseSign: Failed to get client replica")
		return
	end

	self:ToggleVisible(not v3.Data.Settings.HideHouseSign)
	self._Janitor:Add(v3:OnSet({ "Settings", "HideHouseSign" }, function(p)
		self:ToggleVisible(not p)
	end), "Disconnect")
end

function v:Stop()
	self:ToggleVisible(true)
	self._Janitor:Destroy()
end

return v