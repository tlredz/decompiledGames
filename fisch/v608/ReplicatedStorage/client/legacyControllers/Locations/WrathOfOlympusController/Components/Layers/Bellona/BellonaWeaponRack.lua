local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local Replion = require(packages.Replion)
local v = Component.new({
	Tag = "BellonaWeaponRack",
	Ancestors = { Workspace }
})

function v:Construct()
	self.trove = Trove.new()
	local instance = self.Instance

	if not instance:IsA("Model") then
		return
	end

	local swords = instance:FindFirstChild("Swords")

	if not swords then
		return
	end

	self.swords = {}

	for _, child in ipairs(swords:GetChildren()) do
		if child:IsA("Model") or child:IsA("BasePart") then
			table.insert(self.swords, child)
		end
	end

	self.model = instance
	self.replion = Replion.Client:WaitReplion("BellonaRoyalGuards")
end

local function setVisible(part, flag: boolean)
	if part:IsA("BasePart") then
		part.Transparency = flag and 0 or 1
	end

	for _, part2 in ipairs(part:GetDescendants()) do
		if part2:IsA("BasePart") then
			part2.Transparency = flag and 0 or 1
		end
	end
end

function v:_apply()
	if not (self.replion and self.swords) then
		return
	end

	local swordsPlaced = self.replion:Get("SwordsPlaced") or 0

	for i, sword in ipairs(self.swords) do
		setVisible(sword, i <= swordsPlaced)
	end

	local guard3 = (self.replion:Get("RoyalGuards") or {}).Guard3 == true

	for _, proximityPrompt in ipairs(self.model:GetDescendants()) do
		if proximityPrompt:IsA("ProximityPrompt") then
			proximityPrompt.Enabled = not guard3
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