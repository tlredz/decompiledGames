local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local Replion = require(packages.Replion)
local v = Component.new({
	Tag = "HadesStatue",
	Ancestors = { Workspace }
})

function v:Construct()
	self.trove = Trove.new()
	self.replion = Replion.Client:WaitReplion("HadesDarkGate")
end

function v:_apply()
	if not self.replion then
		return
	end

	local v2 = self.replion:Get("GateOpen") == true
	local primaryPart

	if self.Instance:IsA("Model") then
		primaryPart = self.Instance.PrimaryPart
	else
		primaryPart = self.Instance
	end

	if not primaryPart then
		return
	end

	local proximityPrompt = primaryPart:FindFirstChildWhichIsA("ProximityPrompt")

	if proximityPrompt then
		proximityPrompt.Enabled = not v2
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