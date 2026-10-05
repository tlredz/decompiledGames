local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local packages = ReplicatedStorage:WaitForChild("packages")
local Component = require(packages:WaitForChild("Component"))
local Trove = require(packages:WaitForChild("Trove"))
local _ = Players.LocalPlayer
local cycle = ReplicatedStorage:WaitForChild("world"):WaitForChild("cycle")
local v = Component.new({
	Tag = "CycleToggle",
	Ancestors = { workspace }
})

function v:Construct()
	self.trove = Trove.new()
	self.DayModel = self.Instance:WaitForChild("Day")
	self.NightModel = self.Instance:WaitForChild("Night")
end

function v:UpdateModel(folder, flag: boolean)
	local v2 = folder.Name == cycle.Value

	for _, descendant in folder:GetDescendants() do
		if not (descendant:IsA("BasePart") or descendant:IsA("Decal") or descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or descendant:IsA("Beam") or descendant:IsA("Fire") or descendant:IsA("Smoke") or descendant:IsA("Sparkles") or descendant:IsA("Explosion")) then
			continue
		end

		if flag then
			descendant.LocalTransparencyModifier = v2 and 0 or 1
		else
			TweenService:Create(descendant, TweenInfo.new(1, Enum.EasingStyle.Linear), {
				LocalTransparencyModifier = v2 and 0 or 1
			}):Play()
		end
	end
end

function v:Update(flag: boolean)
	v:UpdateModel(self.DayModel, flag)
	v:UpdateModel(self.NightModel, flag)
end

function v:Start()
	self:Update(true)
	self.trove:Add(cycle.Changed:Connect(function()
		self:Update(false)
	end))
end

function v.Stop(p)
	p.trove:Clean()
end

return v