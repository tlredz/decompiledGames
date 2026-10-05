game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ServerScriptService")
local Players = game:GetService("Players")
game:GetService("RunService")
game:GetService("TweenService")
local localPlayer = Players.LocalPlayer
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
local v = Component.new({
	Tag = "RodMusic"
})

function v:Construct()
	self.trove = Trove.new()

	if not self.Instance:GetAttribute("OriginalVolume") then
		self.Instance:SetAttribute("OriginalVolume", self.Instance.Volume)
	end
end

function v:IsLocal()
	local owner = self.Instance:GetAttribute("Owner") or self.Instance.Parent and self.Instance.Parent:GetAttribute("Owner")

	if owner then
		return owner == localPlayer.Name
	end

	local playerFromCharacter = Players:GetPlayerFromCharacter((self.Instance:FindFirstAncestorOfClass("Model")))
	return not playerFromCharacter or playerFromCharacter.Name == localPlayer.Name
end

function v:Update(p2: number)
	self.Instance.Volume = (self.Instance:GetAttribute("OriginalVolume") or 1) * (p2 / 100)
end

function v:Start()
	local v2 = self:IsLocal() and "rodVolumeSelf" or "rodVolumeOthers"
	self:Update(SettingsController:GetSettingValue(v2))
	self.trove:Add(SettingsController:GetSettingChangedSignal(v2):Connect(function(p)
		self:Update(p)
	end))
end

function v.Stop(p)
	p.trove:Clean()
end

return v