local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local packages = ReplicatedStorage:WaitForChild("packages")
local Component = require(packages:WaitForChild("Component"))
local Trove = require(packages:WaitForChild("Trove"))
local localPlayer = Players.LocalPlayer
local v = Component.new({
	Tag = "RodBodyModel"
})

function v:Construct()
	self.trove = Trove.new()
end

function v:UpdateTransparency(instance, flag: boolean)
	local isVisible = self.Instance:GetAttribute("IsVisible")

	if isVisible and self.Instance.Parent and self.Instance.Parent:IsA("Model") and self.Instance.Parent.PrimaryPart then
		isVisible = self.Instance.Parent.PrimaryPart.LocalTransparencyModifier < 0.5
	end

	if instance:IsA("BasePart") or instance:IsA("Decal") or instance:IsA("ParticleEmitter") or instance:IsA("Trail") or instance:IsA("Beam") or instance:IsA("Fire") or instance:IsA("Smoke") or instance:IsA("Sparkles") or instance:IsA("Explosion") then
		instance.LocalTransparencyModifier = isVisible and 0 or 1
	elseif instance:IsA("Sound") then
		local v2 = nil

		if instance.Name ~= "Back" then
			if instance.Name == "Idle" then
				isVisible = not isVisible
			else
				isVisible = instance.Name == "Loop" or instance.Name == "loop" or v2
			end
		end

		if isVisible == true and not instance.Playing and (instance.Looped or flag) then
			instance:Play()
		elseif isVisible == false and instance.Playing then
			instance:Stop()
		end
	elseif instance:IsA("Light") or instance:IsA("LayerCollector") then
		if instance:GetAttribute("OriginalEnabled") == nil then
			instance:SetAttribute("OriginalEnabled", instance.Enabled)
		end

		local enabled

		if isVisible then
			enabled = instance:GetAttribute("OriginalEnabled")
		else
			enabled = false
		end

		instance.Enabled = enabled
	end
end

function v:UpdateFull(flag: boolean)
	for _, descendant in self.Instance:GetDescendants() do
		self:UpdateTransparency(descendant, flag)
	end
end

function v:Start()
	for _, descendant in self.Instance:GetDescendants() do
		if descendant:HasTag("DontShowOnBody") then
			descendant:Destroy()
		end
	end

	self.trove:Add(self.Instance:GetAttributeChangedSignal("IsVisible"):Connect(function()
		self:UpdateFull(true)
	end))
	self.trove:Add(self.Instance.DescendantAdded:Connect(function(descendant)
		self:UpdateTransparency(descendant, true)
	end))
	self:UpdateFull(true)

	if self.Instance:GetAttribute("OwnerId") == localPlayer.UserId then
		self.trove:Add(self.Instance.PrimaryPart:GetPropertyChangedSignal("LocalTransparencyModifier"):Connect(function()
			task.defer(function()
				self:UpdateFull(false)
			end)
		end))
	end

	local primaryPart = self.Instance.Parent and self.Instance.Parent:IsA("Model") and self.Instance.Parent.PrimaryPart

	if primaryPart then
		self.trove:Add(primaryPart:GetPropertyChangedSignal("LocalTransparencyModifier"):Connect(function()
			self:UpdateFull(false)
		end))
	end
end

function v:Stop()
	if self.trove then
		self.trove:Clean()
	end
end

return v