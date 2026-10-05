local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local packages = ReplicatedStorage:WaitForChild("packages")
local Component = require(packages:WaitForChild("Component"))
local Trove = require(packages:WaitForChild("Trove"))
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
local _ = Players.LocalPlayer
local v = Component.new({
	Tag = "EnvironmentTint",
	Ancestors = { game:GetService("Lighting") }
})

function v:Construct()
	self.trove = Trove.new()
end

function v:Update()
	self.Instance.Enabled = SettingsController:GetSettingValue("enableTints")
end

function v:Start()
	self.trove:Add(SettingsController:GetSettingChangedSignal("enableTints"):Connect(function()
		self:Update()
	end))
	self:Update()
end

function v.Stop(p)
	if p.trove then
		p.trove:Clean()
	end
end

return v