local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local packages = ReplicatedStorage:WaitForChild("packages")
local Component = require(packages:WaitForChild("Component"))
local Trove = require(packages:WaitForChild("Trove"))
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
local localPlayer = Players.LocalPlayer
local v = Component.new({
	Tag = "AdminEventVFX",
	Ancestors = { workspace, game:GetService("Lighting") }
})

function v:Construct()
	self.trove = Trove.new()
end

function v:UpdateTransparency(instance)
	local settingValue = SettingsController:GetSettingValue("adminEventVfx")

	if instance:IsA("BasePart") or instance:IsA("Decal") or instance:IsA("ParticleEmitter") or instance:IsA("Trail") or instance:IsA("Beam") or instance:IsA("Fire") or instance:IsA("Smoke") or instance:IsA("Sparkles") or instance:IsA("Explosion") then
		instance.LocalTransparencyModifier = settingValue and 0 or 1
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
	elseif instance:IsA("Atmosphere") then
		if instance:GetAttribute("OriginalDensity") == nil then
			instance:SetAttribute("OriginalDensity", instance.Density)
		end

		instance.Density = not settingValue and 0.35 or instance:GetAttribute("OriginalDensity")
	elseif instance:IsA("PostEffect") then
		instance.Enabled = settingValue
	end
end

function v:UpdateFull()
	for _, descendant in self.Instance:GetDescendants() do
		self:UpdateTransparency(descendant)
	end

	self:UpdateTransparency(self.Instance)
end

function v:Start()
	if localPlayer.Character and self.Instance:IsDescendantOf(localPlayer.Character) then
		return
	end

	self.trove:Add(SettingsController:GetSettingChangedSignal("adminEventVfx"):Connect(function()
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