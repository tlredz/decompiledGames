local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("packages")
local Component = require(packages:WaitForChild("Component"))
local Trove = require(packages:WaitForChild("Trove"))
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
local v = Component.new({
	Tag = "HidePhotosensitive"
})

function v:Construct()
	self.trove = Trove.new()
end

function v:UpdateTransparency(instance)
	if not SettingsController:GetSettingValue("photosensitiveMode") then
		return
	end

	if instance:IsA("BasePart") or instance:IsA("Decal") or instance:IsA("ParticleEmitter") or instance:IsA("Trail") or instance:IsA("Beam") or instance:IsA("Fire") or instance:IsA("Smoke") or instance:IsA("Sparkles") or instance:IsA("Explosion") then
		instance.LocalTransparencyModifier = 1
	elseif instance:IsA("Light") then
		instance.Enabled = false
	end
end

function v:Start()
	self.trove:Add(SettingsController:GetSettingChangedSignal("photosensitiveMode"):Connect(function()
		self:UpdateTransparency(self.Instance)
	end))
	self.trove:Add(self.Instance:GetPropertyChangedSignal(self.Instance:IsA("Light") and "Enabled" or "LocalTransparencyModifier"):Connect(function()
		local v2

		if self.Instance:IsA("Light") then
			v2 = self.Enabled == false
		else
			v2 = self.Instance.LocalTransparencyModifier >= 1
		end

		if not v2 then
			self:UpdateTransparency(self.Instance)
		end
	end))
	self.trove:Add(self.Instance.DescendantAdded:Connect(function(descendant)
		self:UpdateTransparency(descendant)
	end))
	self:UpdateTransparency(self.Instance)
end

function v.Stop(p)
	if p.trove then
		p.trove:Clean()
	end
end

return v