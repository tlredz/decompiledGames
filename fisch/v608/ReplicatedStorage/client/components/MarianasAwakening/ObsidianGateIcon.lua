local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local localPlayer = Players.LocalPlayer
local neon = Enum.Material.Neon
local slate = Enum.Material.Slate
local v = Component.new({
	Tag = "ObsidianGateIcon",
	Ancestors = { workspace }
})

local function getMutation(instance)
	local mutation = instance:GetAttribute("Mutation")

	if typeof(mutation) == "string" and mutation ~= "" then
		return mutation
	end

	return instance.Name
end

local function shouldGlow(p: string?)
	if localPlayer:GetAttribute("ObsidianGateOpened") == true then
		return true
	end

	return p ~= nil and localPlayer:GetAttribute("ObsidianRiddle") == p
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getOrder(instance)
	local order = instance:GetAttribute("Order")

	if typeof(order) == "number" then
		return order
	end

	return 1e999
end

local function getSequenceIndex(instance)
	local obsidianRiddle = localPlayer:GetAttribute("ObsidianRiddle")
	local mutation = instance:GetAttribute("Mutation")

	if typeof(mutation) ~= "string" or mutation == "" then
		mutation = instance.Name
	end

	if mutation == obsidianRiddle then
		return nil
	end

	local parts = {}

	for _, part in CollectionService:GetTagged("ObsidianGateIcon") do
		if not (part:IsA("BasePart") and part:IsDescendantOf(workspace)) then
			continue
		end

		local mutation2 = part:GetAttribute("Mutation")

		if typeof(mutation2) ~= "string" or mutation2 == "" then
			mutation2 = part.Name
		end

		if mutation2 ~= obsidianRiddle then
			table.insert(parts, part)
		end
	end

	table.sort(parts, function(a, b)
		local order = getOrder(a) -- equivalent call inferred; original call site unknown
		local order2 = getOrder(b) -- equivalent call inferred; original call site unknown

		if order == order2 then
			return a.Name < b.Name
		end

		return order < order2
	end)
	return table.find(parts, instance)
end

function v:Construct()
	self.trove = Trove.new()
	local instance = self.Instance
	local mutation = instance:GetAttribute("Mutation")

	if typeof(mutation) ~= "string" or mutation == "" then
		mutation = instance.Name
	end

	self.mutation = mutation
	self.lit = nil
	local instance2 = self.Instance

	if not instance2:IsA("BasePart") then
		return
	end

	local glowColor = instance2:GetAttribute("GlowColor")

	if typeof(glowColor) ~= "Color3" then
		glowColor = instance2.Color
		instance2:SetAttribute("GlowColor", glowColor)
	end

	self.litColor = glowColor
	self.dimColor = glowColor:Lerp(Color3.new(0, 0, 0), 0.8)
end

function v:_render(enabled: boolean, flag: boolean)
	local instance = self.Instance
	local material

	if enabled then
		material = neon
	else
		material = slate
	end

	instance.Material = material

	for _, descendant in instance:GetDescendants() do
		if descendant:IsA("PointLight") or descendant:IsA("SpotLight") or descendant:IsA("SurfaceLight") then
			descendant.Enabled = enabled
		elseif enabled and not flag and descendant:IsA("Sound") then
			descendant:Play()
		end
	end

	local litColor

	if enabled then
		litColor = self.litColor
	else
		litColor = self.dimColor
	end

	if flag then
		instance.Color = litColor
		return
	end

	local tween = TweenService:Create(instance, TweenInfo.new(0.6), {
		Color = litColor
	})
	self.trove:Add(tween)
	tween:Play()
end

function v:_apply(flag: boolean)
	local instance = self.Instance

	if not (instance:IsA("BasePart") and self.litColor) then
		return
	end

	local mutation = self.mutation
	local lit

	if localPlayer:GetAttribute("ObsidianGateOpened") == true then
		lit = true
	elseif mutation == nil then
		lit = false
	else
		lit = localPlayer:GetAttribute("ObsidianRiddle") == mutation
	end

	if lit == self.lit then
		return
	end

	self.lit = lit
	local v3

	if lit and not flag and localPlayer:GetAttribute("ObsidianGateOpened") == true then
		v3 = getSequenceIndex(instance)
	end

	if v3 then
		self.trove:Add(task.delay(v3 * 0.5, function()
			self:_render(true, false)
		end))
	else
		self:_render(lit, flag)
	end
end

function v:Start()
	if not self.litColor then
		warn((`[ObsidianGateIcon] {self.Instance:GetFullName()} is not a BasePart`))
		return
	end

	self:_apply(true)
	self.trove:Add(localPlayer:GetAttributeChangedSignal("ObsidianRiddle"):Connect(function()
		self:_apply(false)
	end))
	self.trove:Add(localPlayer:GetAttributeChangedSignal("ObsidianGateOpened"):Connect(function()
		self:_apply(false)
	end))
end

function v.Stop(p)
	p.trove:Destroy()
end

return v