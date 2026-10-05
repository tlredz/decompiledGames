local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local Replion = require(packages.Replion)
local v = Component.new({
	Tag = "BellonaShieldFragment",
	Ancestors = { Workspace }
})

local function setModelVisible(folder, flag: boolean)
	for _, part in ipairs(folder:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Transparency = flag and 0 or 1
		end
	end
end

function v:Construct()
	self.trove = Trove.new()
	local instance = self.Instance

	if not instance:IsA("Model") then
		return
	end

	self.fragmentId = instance:GetAttribute("FragmentId")

	if not self.fragmentId then
		return
	end

	self.model = instance
	self.replion = Replion.Client:WaitReplion("BellonaRoyalGuards")
end

function v:_apply()
	if not (self.replion and self.model) then
		return
	end

	local v2 = (self.replion:Get("ShieldFragments") or {})[self.fragmentId] == true
	setModelVisible(self.model, not v2)

	for _, proximityPrompt in ipairs(self.model:GetDescendants()) do
		if proximityPrompt:IsA("ProximityPrompt") then
			proximityPrompt.Enabled = not v2
		end
	end
end

function v:Start()
	if not self.replion then
		return
	end

	self:_apply()
	self.trove:Add(self.replion:OnDataChange(function()
		self:_apply()
	end))
end

function v.Stop(p)
	p.trove:Clean()
end

return v