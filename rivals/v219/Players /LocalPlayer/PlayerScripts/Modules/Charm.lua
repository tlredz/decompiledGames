local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local SeasonLibrary = require(ReplicatedStorage.Modules.SeasonLibrary)
local Spring = require(ReplicatedStorage.Modules.Spring)
local charms = Players.LocalPlayer.PlayerScripts.Assets.Charms
local cframe = CFrame.Angles(0.7853981633974483, 0, 0)
local v = {
	X = createVector(1, 0, 0),
	Y = createVector(0, 1, 0),
	Z = createVector(0, 0, 1)
}
local v2 = { 6.283185307179586, -6.283185307179586 }
local Charm = {}
Charm.__index = Charm

function Charm.new(clientViewModel, equippedData, charm_pivot_attachment)
	local self = setmetatable({}, Charm)
	self.ClientViewModel = clientViewModel
	self.EquippedData = equippedData
	self.Name = self.EquippedData.Name
	self.Model = charms[self.Name]:Clone()
	self._original_scale = self.Model:GetScale()
	self._charm_pivot_attachment = charm_pivot_attachment
	self._pivot_attachment = self.Model:FindFirstChild("_pivot_attachment", true)
	self._pivot_charm_scale = self._charm_pivot_attachment:GetAttribute("CharmScale") or 1
	self._orientation_spring = Spring.new(createVector(0, 0, 0), 0.25, 10)
	self._no_physics = self._charm_pivot_attachment:GetAttribute("NoPhysics")
	self._hide_until = 0
	self:_Init()
	return self
end

function Charm.SetParent(p, parent)
	p.Model.Parent = parent
end

function Charm:ScaleTo(p)
	self.Model:ScaleTo(self._original_scale * self._pivot_charm_scale * p)
end

function Charm.SetHidden(p, p2)
	local localTransparencyModifier = p2 and 1 or 0

	for _, descendant in pairs(p.Model:GetDescendants()) do
		if not (descendant:IsA("BasePart") or descendant:IsA("Texture") or descendant:IsA("Beam") or descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or descendant:IsA("Decal")) then
			continue
		end

		descendant.LocalTransparencyModifier = localTransparencyModifier
	end
end

function Charm:Update(_, p)
	if p or self._no_physics then
		self.Model:PivotTo(self._charm_pivot_attachment.WorldCFrame)
		return
	end

	local vector2 = Vector3.new(
		self._charm_pivot_attachment.WorldCFrame.LookVector.X,
		-1,
		self._charm_pivot_attachment.WorldCFrame.LookVector.Z
	)
	local v3 = CFrame.new(createVector(0, 0, 0), vector2) * cframe * (self.ClientViewModel and CFrame.Angles(
		0,
		0,
		-self.ClientViewModel.CurrentSwayValue.Y * 5
	) or CFrame.identity)
	local cframe2 = self._charm_pivot_attachment.WorldCFrame.Rotation:ToObjectSpace(v3)
	self._orientation_spring.Target = Vector3.new(cframe2:ToOrientation())

	for k, v4 in pairs(v) do
		for _, v5 in pairs(v2) do
			if not (math.abs(self._orientation_spring.Value[k] - (self._orientation_spring.Target[k] + v5)) < math.abs(self._orientation_spring.Value[k] - self._orientation_spring.Target[k])) then
				continue
			end

			self._orientation_spring.Value -= v4 * v5
		end
	end

	local value = self._orientation_spring.Value
	local v4 = self._charm_pivot_attachment.WorldCFrame * CFrame.fromOrientation(value.X, value.Y, value.Z)
	self.Model:PivotTo(v4)
end

function Charm:Destroy()
	self.Model:Destroy()
end

function Charm._SetupSeasonRankCharm(data)
	if #data.Name < 8 or string.sub(data.Name, 1, 7) ~= "Season " then
		return
	end

	local v3 = tonumber((string.sub(data.Name, 8)))

	if not v3 then
		return
	end

	local name = SeasonLibrary.SeasonsByVersion[v3].Name
	local seasonELO

	if data.EquippedData.Metadata then
		seasonELO = data.EquippedData.Metadata.SeasonELO or nil
	end

	local v4

	if data.EquippedData.Metadata then
		v4 = data.EquippedData.Metadata.SeasonLeaderboardRank or nil
	end

	SeasonLibrary:FormatSeasonRankCharm(data.Model, name, seasonELO, v4)
end

function Charm:_Setup()
	assert(self._pivot_attachment ~= nil, self.Name)

	if self._no_physics and self.Model:FindFirstChild("Hook") then
		self.Model.Hook:Destroy()
	end

	self.Model.WorldPivot = self._no_physics and self.Model.Primary.CFrame or self._pivot_attachment.WorldCFrame
	self.Model.PrimaryPart = nil

	for _, part in pairs(self.Model:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		part.CastShadow = false
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Massless = true
		part.Anchored = true
	end

	if self.Model:FindFirstChild("Hook") and self.Model.Hook:FindFirstChild("Ring") then
		self.Model.Hook.Ring.Material = Enum.Material.Glass
	end

	if self._pivot_charm_scale ~= 1 then
		self:ScaleTo(1)
	end
end

function Charm:_Init()
	self:_Setup()
	task.defer(self._SetupSeasonRankCharm, self)
end

return Charm