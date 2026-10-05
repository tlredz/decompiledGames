local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("packages")
local Component = require(packages:WaitForChild("Component"))
local Trove = require(packages:WaitForChild("Trove"))
local v = Component.new({
	Tag = "EverturnEyes"
})
local cycle = ReplicatedStorage:WaitForChild("world"):WaitForChild("cycle")

function v:Construct()
	self.trove = Trove.new()
end

function v:Update()
	if not self.Instance:GetAttribute("OriginalColor") then
		self.Instance:SetAttribute("OriginalColor", self.Instance.Color)
	end

	if not self.Instance:GetAttribute("OriginalMaterial") then
		self.Instance:SetAttribute("OriginalMaterial", self.Instance.Material)
	end

	if cycle.Value == "Night" then
		self.Instance.Color = Color3.fromRGB(255, 131, 131)
		self.Instance.Material = Enum.Material.Neon
	else
		self.Instance.Color = self.Instance:GetAttribute("OriginalColor")
		self.Instance.Material = self.Instance:GetAttribute("OriginalMaterial")
	end
end

function v:Start()
	self.trove:Connect(ReplicatedStorage.world.cycle.Changed, function()
		self:Update()
	end)
	self:Update()
end

function v.Stop(p)
	p.trove:Clean()
end

return v