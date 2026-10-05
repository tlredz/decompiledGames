local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local packages = ReplicatedStorage:WaitForChild("packages")
local Component = require(packages:WaitForChild("Component"))
local Trove = require(packages:WaitForChild("Trove"))
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
local localPlayer = Players.LocalPlayer
local v = Component.new({
	Tag = "VisibleFish"
})

function v:Construct()
	self.trove = Trove.new()
end

function v:UpdateTransparency(instance)
	local settingValue = SettingsController:GetSettingValue("showHeldFish")

	if instance:IsA("BasePart") or instance:IsA("Decal") or instance:IsA("ParticleEmitter") or instance:IsA("Trail") or instance:IsA("Beam") or instance:IsA("Fire") or instance:IsA("Smoke") or instance:IsA("Sparkles") or instance:IsA("Explosion") then
		instance.LocalTransparencyModifier = settingValue and 0 or 1
	elseif instance:IsA("Sound") then
		if not instance:GetAttribute("OriginalVolume") then
			instance:SetAttribute("OriginalVolume", instance.Volume)
		end

		instance.Volume = not settingValue and 0 or instance:GetAttribute("OriginalVolume") or 0
	elseif instance:IsA("Light") or instance:IsA("LayerCollector") then
		if instance:GetAttribute("OriginalEnabled") == nil then
			instance:SetAttribute("OriginalEnabled", instance.Enabled)
		end

		local enabled

		if settingValue then
			enabled = instance:GetAttribute("OriginalEnabled")
		else
			enabled = false
		end

		instance.Enabled = enabled
	end
end

function v:UpdateFull()
	for _, descendant in self.Instance:GetDescendants() do
		self:UpdateTransparency(descendant)
	end
end

function v:Start()
	if localPlayer.Character and self.Instance:IsDescendantOf(localPlayer.Character) then
		return
	end

	self.trove:Add(SettingsController:GetSettingChangedSignal("showHeldFish"):Connect(function()
		self:UpdateFull()
	end))
	self.trove:Add(self.Instance.DescendantAdded:Connect(function(descendant)
		self:UpdateTransparency(descendant)
	end))
	self:UpdateFull()
end

function v.Stop(p)
	if p.trove then
		p.trove:Clean()
	end
end

return v