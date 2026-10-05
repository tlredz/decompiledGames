local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local packages = ReplicatedStorage:WaitForChild("packages")
local Component = require(packages:WaitForChild("Component"))
local Trove = require(packages:WaitForChild("Trove"))
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
local _ = Players.LocalPlayer
local v = Component.new({
	Tag = "VisibleFishInfo"
})

function v:Construct()
	self.trove = Trove.new()
end

function v:UpdateVisibility()
	self.Instance.Enabled = SettingsController:GetSettingValue("heldFishInfo")
end

function v:Start()
	self.trove:Add(SettingsController:GetSettingChangedSignal("heldFishInfo"):Connect(function()
		self:UpdateVisibility()
	end))
	self:UpdateVisibility()
end

function v.Stop(p)
	if p.trove then
		p.trove:Clean()
	end
end

return v