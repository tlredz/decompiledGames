game:GetService("RunService")
game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.packages
require(packages.Cache)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local utilities = ReplicatedStorage.resources.replicated.instances.utilities
local v = {
	{
		targetType = "lobster",
		displayName = "Cage",
		defaultObject = "Old Cage",
		scale = 1
	},
	{
		targetType = "school",
		displayName = "Net",
		defaultObject = "Fishing Net",
		scale = 6
	}
}
local v2 = Component.new({
	Tag = "UtilityAttachment"
})

function v2:Construct()
	self.trove = Trove.new()
	local model = self.Instance:FindFirstAncestorOfClass("Model")

	if model then
		model:FindFirstChild("Information")
	end

	self.boat = model
	self.currentType = 1
	self.objectTrove = self.trove:Extend()
end

function v2:UpdateCurrentType()
	self.objectTrove:Clean()
	self.currentType = self.Instance:GetAttribute("CurrentType") or 1
	local clone = utilities:FindFirstChild(v[self.currentType].defaultObject):Clone()
	self.objectTrove:Add(clone)
	clone:PivotTo(self.Instance.WorldCFrame)
	clone:ScaleTo(v[self.currentType].scale or 1)

	for _, part in clone:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = false
		part.Massless = true
		part.RootPriority = -127

		if part == clone.PrimaryPart then
			continue
		end

		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = clone.PrimaryPart
		weldConstraint.Part1 = part
		weldConstraint.Parent = clone.PrimaryPart
	end

	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = clone.PrimaryPart
	weldConstraint.Part1 = self.boat.PrimaryPart
	weldConstraint.Parent = self.boat.PrimaryPart
	self.objectTrove:Add(weldConstraint)
	clone.Parent = self.boat.PrimaryPart.Parent
end

function v2:Start()
	DataController.PlayerDataReplicator:Observe({ "UnlockedFromNPCs" }, function(p)
		if not p then
			return
		end

		local prompt = self.Instance:WaitForChild("Prompt")
		prompt.Enabled = p.Nets ~= nil and p.Nets
	end)
	self.trove:Connect(self.Instance:GetAttributeChangedSignal("CurrentType"), function()
		self:UpdateCurrentType()
	end)
	self:UpdateCurrentType()
end

function v2.Stop(p)
	p.trove:Destroy()
end

return v2