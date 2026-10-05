local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local localPlayer = Players.LocalPlayer
local v = Component.new({
	Tag = "ObsidianGate",
	Ancestors = { workspace }
})

local function getPrimary(instance)
	if instance:IsA("BasePart") then
		return instance
	end

	if instance:IsA("Model") then
		return instance.PrimaryPart or instance:FindFirstChildWhichIsA("BasePart")
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isOpen()
	return localPlayer:GetAttribute("ObsidianGateOpened") == true
end

local function getIconMutation(instance)
	local mutation = instance:GetAttribute("Mutation")

	if typeof(mutation) == "string" and mutation ~= "" then
		return mutation
	end

	return instance.Name
end

local function getSequenceDelay()
	local obsidianRiddle = localPlayer:GetAttribute("ObsidianRiddle")
	local count = 0

	for _, part in CollectionService:GetTagged("ObsidianGateIcon") do
		if not (part:IsA("BasePart") and part:IsDescendantOf(workspace)) then
			continue
		end

		local mutation = part:GetAttribute("Mutation")

		if typeof(mutation) ~= "string" or mutation == "" then
			mutation = part.Name
		end

		if mutation ~= obsidianRiddle then
			count += 1
		end
	end

	return count * 0.5 + 0.5
end

function v:Construct()
	self.trove = Trove.new()
	local instance = self.Instance

	if not instance:IsA("BasePart") then
		if instance:IsA("Model") then
			instance = instance.PrimaryPart or instance:FindFirstChildWhichIsA("BasePart")
		else
			instance = nil
		end
	end

	self.primary = instance
	self.offset = self.Instance:GetAttribute("OpenOffset") or createVector(23.306, 0, 34.88)
	self.duration = self.Instance:GetAttribute("OpenDuration") or 6
	self.opened = false
	local primary = self.primary

	if primary then
		local closedCFrame = primary:GetAttribute("ClosedCFrame")

		if typeof(closedCFrame) ~= "CFrame" then
			closedCFrame = primary.CFrame
			primary:SetAttribute("ClosedCFrame", closedCFrame)
		end

		self.closedCFrame = closedCFrame
		self.openCFrame = closedCFrame + self.offset
	end
end

function v:_playSounds()
	local primary = self.primary

	if not primary then
		return
	end

	for _, sound in primary:GetChildren() do
		if sound:IsA("Sound") then
			sound:Play()
		end
	end
end

function v:_tween(flag: boolean)
	local primary = self.primary

	if not primary then
		return
	end

	local tweenInfo = TweenInfo.new(self.duration, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	local cFrame

	if flag then
		cFrame = self.openCFrame
	else
		cFrame = self.closedCFrame
	end

	local v5 = TweenService:Create(primary, tweenInfo, {
		CFrame = cFrame
	})
	self.trove:Add(v5)
	v5:Play()

	if flag then
		self:_playSounds()
	end
end

function v:_apply(flag: boolean)
	local primary = self.primary

	if not primary then
		return
	end

	local open = isOpen() -- equivalent call inferred; original call site unknown

	if open == self.opened then
		return
	end

	self.opened = open

	if flag then
		local cFrame

		if open then
			cFrame = self.openCFrame
		else
			cFrame = self.closedCFrame
		end

		primary.CFrame = cFrame
	elseif open then
		self.trove:Add(task.delay(getSequenceDelay(), function()
			self:_tween(true)
		end))
	else
		self:_tween(false)
	end
end

function v:Start()
	if not self.primary then
		warn((`[ObsidianGateDoor] {self.Instance:GetFullName()} has no part to move`))
		return
	end

	self:_apply(true)
	self.trove:Add(localPlayer:GetAttributeChangedSignal("ObsidianGateOpened"):Connect(function()
		self:_apply(false)
	end))
end

function v.Stop(p)
	p.trove:Destroy()
end

return v